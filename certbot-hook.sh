#!/bin/bash

if [ -z "$CERTBOT_DOMAIN" ] || [ -z "$CERTBOT_VALIDATION" ]
then
    echo "EMPTY DOMAIN OR VALIDATION"
    exit 1
fi

# load env variables since they are not available in a dynect hook by default
source /etc/environment

echo "Adding ${CERTBOT_VALIDATION} for ${CERTBOT_DOMAIN}"
/usr/bin/python3 $(pwd)/update-dynect.py $CERTBOT_DOMAIN $CERTBOT_VALIDATION
echo "Now waiting for 60 seconds"
sleep 60
exit $?
