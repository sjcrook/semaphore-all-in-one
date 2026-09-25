#!/bin/bash
set -e

echo "Starting Semaphore services..."

export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto/
export SEMAPHORE_DEFAULT_BACKEND=MARKLOGIC
export SEMAPHORE_MARKLOGIC_CONFIG=$MARKLOGIC_ADMIN_USERNAME:$MARKLOGIC_ADMIN_PASSWORD@marklogic://marklogic:8000/${MARKLOGIC_SEMAPHORE_DATABASE}
# Keep workbench path scoped to KMM only to avoid cross-service lock contention.

# Track PIDs of started services
pids=()

shutdown() {
    echo "Shutting down cleanly..."

    # Send SIGTERM to all background processes
    for i in "${!pids[@]}"; do
        pid=${pids[$i]}
        name=${names[$i]}
        if kill -0 "$pid" 2>/dev/null; then
            echo "Sending SIGTERM to $name (PID $pid)..."
            kill -TERM "$pid"
        fi
    done

    # Wait for them to exit
    for pid in "${pids[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            echo "Waiting for PID $pid to exit..."
            wait "$pid"
            echo "PID $pid stopped."
        fi
    done

    echo "All subprocesses stopped. Exiting."
    exit 0
}

trap shutdown SIGHUP SIGINT SIGTERM

# --- Configuration and startup ---
sed -i \
    -e "s/SEMAPHORE_SUPER_ADMINISTRATOR_PASSWORD/${SEMAPHORE_SUPER_ADMINISTRATOR_PASSWORD}/" \
    /opt/semaphore/studio/conf/studio-authentication.properties

cd /opt/semaphore
/opt/semaphore/create-marklogic-database-for-semaphore.sh

start_service() {
    name=$1
    dir=$2
    cmd=$3

    echo "Starting $name"
    cd "$dir"
    "$cmd" &
    pid=$!
    echo "$name started with PID $pid"
    pids+=($pid)
    names+=("$name")
}

# Start services
start_service "Studio" /opt/semaphore /opt/semaphore/start-studio.sh

# Ensure KMM workspace storage is persisted on /var volume.
# KMM currently writes TDB files under /opt/semaphore/kmm/SWH/workspace,
# so we redirect /opt/semaphore/kmm/SWH to /var/opt/semaphore/kmm/SWH.
mkdir -p /var/opt/semaphore/kmm
if [ -L /opt/semaphore/kmm/SWH ]; then
    true
elif [ -d /opt/semaphore/kmm/SWH ]; then
    if [ ! -d /var/opt/semaphore/kmm/SWH ]; then
        mv /opt/semaphore/kmm/SWH /var/opt/semaphore/kmm/SWH
    else
        rm -rf /opt/semaphore/kmm/SWH
    fi
fi
if [ ! -L /opt/semaphore/kmm/SWH ]; then
    ln -s /var/opt/semaphore/kmm/SWH /opt/semaphore/kmm/SWH
fi

# Clear stale Jena TDB lock files left from prior container runs.
# Locks only store a PID; after restart that PID can belong to an unrelated process.
for lock_file in \
    /var/opt/semaphore/kmm/data/workspace/_Data/System/tdb.lock \
    /var/opt/semaphore/kmm/data/workspace/_Data/TDB/tdb.lock \
    /var/opt/semaphore/kmm/SWH/workspace/_Data/System/tdb.lock \
    /var/opt/semaphore/kmm/SWH/workspace/_Data/TDB/tdb.lock
do
    if [ -f "$lock_file" ]; then
        echo "Removing stale KMM TDB lock: $lock_file"
        rm -f "$lock_file"
    fi
done

# KMM's launcher hardcodes an oversized heap. Keep it within the container budget.
sed -i \
    -e 's/-Xms2G -Xmx8G/-Xms1G -Xmx3G/' \
    /opt/semaphore/kmm/bin/start.sh

echo "Starting KMM"
cd /opt/semaphore/kmm
SEMAPHORE_WORKBENCH_HOME=/var/opt/semaphore/kmm/data CATALINA_BASE=/opt/semaphore/kmm /opt/semaphore/kmm/bin/start.sh &
pid=$!
echo "KMM started with PID $pid"
pids+=($pid)
names+=("KMM")
start_service "DA" /opt/semaphore/da /opt/semaphore/da/bin/start.sh
start_service "RM" /opt/semaphore/rm /opt/semaphore/rm/bin/start.sh
start_service "SM" /opt/semaphore/sm /opt/semaphore/sm/bin/start.sh
start_service "CLS" /opt/semaphore /opt/semaphore/start-cs.sh
start_service "SES" /opt/semaphore /opt/semaphore/start-ses.sh
start_service "CONS" /opt/semaphore /opt/semaphore/start-cons.sh

# Main loop — keep container alive
#while true; do
#    sleep 1
#done

wait