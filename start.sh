#!/bin/bash

if [[ -z "$AWS_CERT" && -z "$AWS_PRIVATE_KEY" && -z "$AWS_ROOT_CA" ]]; then
	echo "Creating AWS certificates"
	curl -X POST -H "Cache-Control: no-cache" -H 'Content-Type: application/json' \
	-v -d '{ "uuid": "'$RESIN_DEVICE_UUID'", "attributes": { "deviceType": "'$RESIN_DEVICE_TYPE'",  } }' \
	$LAMBDA
elif [[ "$AWS_CERT" && "$AWS_PRIVATE_KEY" && "$AWS_ROOT_CA" ]]; then
	echo "AWS certificates exist - running app"
	npm start &
fi

./edge-node-manager
