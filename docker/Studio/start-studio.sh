#!/bin/bash

function shutdown {
      exit
}

trap shutdown SIGHUP SIGINT SIGTERM

#start studio
cd /opt/semaphore/studio
/opt/semaphore/studio/bin/start.sh &

cd /opt/semaphore

if [ ! -f "/etc/opt/semaphore/.env_configured" ]; then
    echo
    echo Sleeping for 60s to allow processes to start at `date`
    echo
    sleep 60
    echo
    echo Woken up from 60s sleep at `date`
    echo

    # configure SES, CS and publishing permission defaults on first startup.
    echo Uploading license
    /opt/semaphore/upload-license.sh &> upload-license.log
    echo License uploaded
    echo Creating CLS service
    /opt/semaphore/create-service.sh $EXT_CLS_5058 5058 "" "Classification and Language Service" CreateClassificationService &> create-cls-service.log
    echo CLS service created
    echo Creating SES service
    /opt/semaphore/create-service.sh $EXT_SES_8983 8983 "ses" "Semantic Enhancement Service" CreateSemanticIntegrationService &> create-ses-service.log
    echo SES service created
    echo Creating Concepts service
    /opt/semaphore/create-service.sh $EXT_CONCEPTS_5092 5092 "" "Concepts Service" CreateConceptsService &> create-concepts-service.log
    echo Concepts service created
    echo Creating permissions
    /opt/semaphore/add-superadmin-publish-permission.sh &> add-superadmin-publish-permission.log
    echo Permissions created
    touch "/etc/opt/semaphore/.env_configured"
    echo Environment configured for the first time at `date`
fi
