Prerequisites
=============

You need python3 and the argparse and dynect modules
- pip3 install DynectDNS
- pip3 install argparse

If you are having issues to install dynect, install it from source

    git clone https://github.com/dyninc/Dynect-API-Python-Library.git
    cd Dynect-API-Python-Library
    python3 setup.py install


Usage
=====

Make sure you have set the following environment variables
- export CERTBOT_CUSTOMER_NAME=your-dynect-customer-name
- export CERTBOT_API_KEY=your-api-key
- export CERTBOT_API_PASS=your-api-password


Then call certbot or certbot-auto

    certbot-auto \
      -d *.srf.ch \
      --server https://acme-v02.api.letsencrypt.org/directory \
      --manual \
      --manual-auth-hook /tmp/dynect-test/certbot-hook.sh \
      --manual-public-ip-logging-ok \
      --preferred-challenges dns certonly
