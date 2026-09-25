#!/bin/bash

lowercase_first_char() {
    local input="$1"
    if [ -z "$input" ]; then
        echo ""
    else
        first_char="${input:0:1}"
        rest="${input:1}"
        echo "${first_char,,}$rest"
    fi
}

port=$1
localPort=$2
path=$3
nameDescription=$4
func=$5
lfunc=$(lowercase_first_char "$func")

# cookies_file created in upload-license.sh

curl -v -b cookies_file \
    -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{"query":"{environments {uri label}}\n","variables":null,"operationName":null}' \
    "http://localhost:5080/api/graphql" | jq -r ".data.environments[0].uri" > envUri

envURI=`cat envUri`
echo "Environment url: $envURI"

URL="http://localhost:$port/$path"
echo "URL: $URL"

localURL="http://localhost:$localPort/$path"
echo "Local URL: $localURL"

#
# generate uuid for the new service
#

uuid=`uuidgen | awk '{print tolower($0)}'`
serviceUUID="urn:uuid:$uuid"

#
# create JSON payload for graphQL request
# 

read -r -d '' createPayloadJson << EOF
{
    "operationName": "$func",
    "variables": {
        "uri": "$serviceUUID",
        "name": "$nameDescription",
        "description": "$nameDescription",
        "url": "$URL",
        "localUrl": "$localURL",
        "environmentUri": "$envURI",
        "cloudApiKey": "",
        "cloudTokenUrl": "",
        "isCloudConfigured": false
    },
    "query": "mutation $func(\$uri: ID, \$name: String, \$description: String, \$url: String, \$localUrl: String, \$environmentUri: ID, \$cloudApiKey: String, \$cloudTokenUrl: String, \$isCloudConfigured: Boolean) {\n  $lfunc(\n    input: {uri: \$uri, name: \$name, description: \$description, url: \$url, localUrl: \$localUrl, environment: {uri: \$environmentUri}, cloudApiKey: \$cloudApiKey, cloudTokenUrl: \$cloudTokenUrl, isCloudConfigured: \$isCloudConfigured}\n  )\n  report {\n    addedCount\n    deletedCount\n    __typename\n  }\n  commit(message: \"Done\")\n}"
}
EOF

echo "payload: $createPayloadJson"

#
# add ClassificationServices instance API call
#

curl -v -b cookies_file \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$createPayloadJson" \
    "http://localhost:5080/api/graphql"
