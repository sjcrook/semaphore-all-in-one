#!/bin/bash

# function shutdown {
#     echo
#     echo "Stopping Semaphore Concept Server"
#     /opt/semaphore/concepts/bin/CSservice.sh stop -force
#     echo

#     exit
# }

sed -e 's/MARKLOGIC_ADMIN_USERNAME/'"$MARKLOGIC_ADMIN_USERNAME"'/' -e 's/MARKLOGIC_ADMIN_PASSWORD/'"$MARKLOGIC_ADMIN_PASSWORD"'/' /opt/semaphore/concepts/conf/marklogic.properties.template > /opt/semaphore/concepts/conf/marklogic.properties

echo "Starting Semaphore Concept Server on port 5092"
cd /opt/semaphore/concepts
./bin/start.sh &
echo