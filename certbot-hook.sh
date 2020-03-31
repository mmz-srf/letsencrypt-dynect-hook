#!/bin/bash

exit 1

function exitIfFailed() {
    exitCode=$1
    if [ $exitCode > 0 ];
        exit $exitCode
    fi
}

function authDynect() {    echo "Adding _acme-challenge entry for ${CERTBOT_DOMAIN_CLEAN} on dynect"
    /usr/bin/python3 $(pwd)/update-dynect.py $CERTBOT_DOMAIN_CLEAN $CERTBOT_VALIDATION
    return $?
}

function authLexicon() {
    PROVIDER=$1
    AUTH=$2

    echo "Adding _acme-challenge entry for ${CERTBOT_DOMAIN_CLEAN} on ${PROVIDER}"
    lexicon $PROVIDER $AUTH \
    create "${CERTBOT_DOMAIN_CLEAN}" TXT --name "_acme-challenge.${CERTBOT_DOMAIN_CLEAN}" --content "${CERTBOT_VALIDATION}"
    return $?
}

function cleanupLexicon() {
    PROVIDER=$1
    AUTH=$2

    echo "Deleting _acme-challenge entry for ${CERTBOT_DOMAIN_CLEAN} on ${PROVIDER}"
    lexicon $PROVIDER $AUTH \
    delete "${CERTBOT_DOMAIN_CLEAN}" TXT --name "_acme-challenge.${CERTBOT_DOMAIN_CLEAN}" --content "${CERTBOT_VALIDATION}"
    return $?
}


function auth() {
    authDynect
    exitIfFailed $?
    
    authLexicon "nsone" "--auth-token=${NSONE_API_KEY}"
    exitIfFailed $?

    authLexicon "route53" "--auth-access-key=${AWS_API_KEY} --auth-access-secret=${AWS_API_SECRET}"
    exitIfFailed $?

    sleep 60
}


function cleanup() {
    cleanupLexicon "nsone" "--auth-token=${NSONE_API_KEY}"
    exitIfFailed $?

    cleanupLexicon "route53" "--auth-access-key=${AWS_API_KEY} --auth-access-secret=${AWS_API_SECRET}"
    exitIfFailed $?
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

exit 0
