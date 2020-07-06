#!/bin/bash

# exit if subcommand exit code is not 0
function exitIfFailed() {
    exitCode=$1
    provider=$2
    if [ $exitCode -ne "0" ]
    then
        echo "Exit Code ${exitCode} is not good - failed on provider ${provider}"
        exit $exitCode
    fi
}

# AWS Plugin
function authAws() {
    echo "Adding _acme-challenge entry for ${CERTBOT_DOMAIN_CLEAN} on AWS"
    /usr/bin/python3 $(pwd)/update-aws.py auth $CERTBOT_DOMAIN_CLEAN $CERTBOT_VALIDATION
}

function cleanupAws() {
    echo "Deleting _acme-challenge entry for ${CERTBOT_DOMAIN_CLEAN} on AWS"
    /usr/bin/python3 $(pwd)/update-aws.py cleanup $CERTBOT_DOMAIN_CLEAN $CERTBOT_VALIDATION
}


# NSONE Plugin
function authNsone() {
    echo "Adding _acme-challenge entry for ${CERTBOT_DOMAIN_CLEAN} on NSONE"
    lexicon nsone --auth-token=${NSONE_API_KEY} \
    create "${CERTBOT_DOMAIN_CLEAN}" TXT --name "_acme-challenge.${CERTBOT_DOMAIN_CLEAN}" --content "${CERTBOT_VALIDATION}"
    return $?
}

function cleanupNsone() {
    echo "Deleting _acme-challenge entry for ${CERTBOT_DOMAIN_CLEAN} on NSONE"
    lexicon nsone --auth-token=${NSONE_API_KEY} \
    delete "${CERTBOT_DOMAIN_CLEAN}" TXT --name "_acme-challenge.${CERTBOT_DOMAIN_CLEAN}" --content "${CERTBOT_VALIDATION}"
    return $?
}


function auth() {
    authAws
    exitIfFailed $? "route53"  
    authNsone
    exitIfFailed $? "nsone"

    sleep 60
}


function cleanup() {
    cleanupAws
    exitIfFailed $? "route53"

    cleanupNsone
    exitIfFailed $? "nsone"
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
if [ -n "$(type -t $HANDLER)" ] && [ "$(type -t $HANDLER)" = function ]
then
    $HANDLER
fi

exit 0
