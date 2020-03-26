#!/bin/bash

function authDynect() {
	echo "Adding _acme-challenge entry for ${CERTBOT_DOMAIN_CLEAN} on dynect"
    /usr/bin/python3 $(pwd)/update-dynect.py "auth" $CERTBOT_DOMAIN_CLEAN $CERTBOT_VALIDATION
    return $?
}

function authNsone() {
    echo "Adding _acme-challenge entry for ${CERTBOT_DOMAIN_CLEAN} on nsone"
    lexicon "nsone" "--auth-token=${NSONE_API_KEY}" \
    create "${CERTBOT_DOMAIN_CLEAN}" TXT --name "_acme-challenge.${CERTBOT_DOMAIN_CLEAN}" --content "${CERTBOT_VALIDATION}"
    return $?
}

function auth() {
    authDynect
    exitCodeDynect=$?
    authNsone
    exitCodeNsone=$?

    sleep 60
}

cleanupNsone() {
    echo "Cleaning up _acme-challenge entry for ${CERTBOT_DOMAIN_CLEAN} on nsone"
	lexicon "nsone" "--auth-token=${NSONE_API_KEY}" \
    delete "${CERTBOT_DOMAIN_CLEAN}" TXT --name "_acme-challenge.${CERTBOT_DOMAIN_CLEAN}" --content "${CERTBOT_VALIDATION}"
    return $?
}

function cleanup() {
	cleanupNsone
    exitCodeNsone=$?
}


if [ -z "$CERTBOT_DOMAIN" ] || [ -z "$CERTBOT_VALIDATION" ]
then
    echo "EMPTY DOMAIN OR VALIDATION"
    exit 1
fi

# remove *. from domain if present
CERTBOT_DOMAIN_CLEAN=$(echo -n $CERTBOT_DOMAIN|sed 's/^\*\.//g')

source .env

HANDLER=$1;
if [ -n "$(type -t $HANDLER)" ] && [ "$(type -t $HANDLER)" = function ]; then
  $HANDLER
fi