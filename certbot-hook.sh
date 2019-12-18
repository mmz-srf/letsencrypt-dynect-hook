#!/bin/bash

printenv
exit 1

if [ -z "$CERTBOT_DOMAIN" ] || [ -z "$CERTBOT_VALIDATION" ]
then
    echo "EMPTY DOMAIN OR VALIDATION"
    exit 1
fi

# load env variables since they are not available in a dynect hook by default
source /etc/environment

/usr/bin/python3 $(pwd)/update-dynect.py $CERTBOT_DOMAIN $CERTBOT_VALIDATION
EXIT_CODE=$?
exit $EXIT_CODE
