#!/bin/bash

if [ ! -f "/etc/opt/semaphore/.marklogic_configured" ]; then
    echo Setting up MarkLogic database for Semaphore

    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
        if [ `curl -s -o /dev/null -w "%{http_code}" --anyauth --user $MARKLOGIC_ADMIN_USERNAME:$MARKLOGIC_ADMIN_PASSWORD -X POST -i -H "Content-type: application/json" -d "{\"forest-name\":\"${MARKLOGIC_SEMAPHORE_DATABASE}\"}" http://marklogic:8002/manage/v2/forests` = "201" ]; then
            echo 
            echo MarkLogic has completed initialization...
            echo 
            break
        fi
        echo Waiting for MarkLogic to complete initialization.  Sleeping for 10s...
        sleep 10
    done

    echo Creating database...

    curl --anyauth --user $MARKLOGIC_ADMIN_USERNAME:$MARKLOGIC_ADMIN_PASSWORD -X POST -i \
    -H "Content-type: application/json" \
    -d "{\"database-name\":\"${MARKLOGIC_SEMAPHORE_DATABASE}\"}" \
    http://marklogic:8002/manage/v2/databases

    echo Attaching forest to database...

    curl --anyauth --user $MARKLOGIC_ADMIN_USERNAME:$MARKLOGIC_ADMIN_PASSWORD -X POST -i \
    -H "Content-type: application/x-www-form-urlencoded" \
    -d "state=attach&database=${MARKLOGIC_SEMAPHORE_DATABASE}" \
    http://marklogic:8002/manage/v2/forests/${MARKLOGIC_SEMAPHORE_DATABASE}

    touch "/etc/opt/semaphore/.marklogic_configured"

    echo Completed the setting up of MarkLogic database for Semaphore
fi
