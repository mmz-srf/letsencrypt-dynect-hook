#!/bin/bash



if [ -z "$CERTBOT_DOMAIN" ] || [ -z "$CERTBOT_VALIDATION" ]
then
    echo "EMPTY DOMAIN OR VALIDATION"
    exit 1
fi

/usr/bin/python3 $(pwd)/update-dynect.py $CERTBOT_DOMAIN $CERTBOT_VALIDATION
EXIT_CODE=$?
exit $EXIT_CODE
