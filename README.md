Prerequisites
=============

You need python3 and the argparse, dotenv and dynect modules
- pip3 install dns-lexicon
- pip3 install DynectDNS
- pip3 install argparse
- pip3 install python-dotenv

If you are having issues to install dynect, install it from source

    git clone https://github.com/dyninc/Dynect-API-Python-Library.git
    cd Dynect-API-Python-Library
    python3 setup.py install


Usage
=====

Make sure you have set the following environment variables in a .env file in the same directory as these scripts.
- CERTBOT_CUSTOMER_NAME=your-dynect-customer-name
- CERTBOT_API_KEY=your-dynect-api-key
- CERTBOT_API_PASS=your-dynect-api-password
- NSONE_API_KEY=your-nsone-api-key
- AWS_API_KEY=very-secret-api-user
- AWS_API_USER=even-more-secret-api-key


Then call certbot or certbot-auto

    certbot-auto \
      --test-cert \
      -d *.srf.ch \
      --server https://acme-v02.api.letsencrypt.org/directory \
      --manual \
      --manual-auth-hook "/tmp/dynect-test/certbot-hook.sh auth" \
      --manual-cleanup-hook "/tmp/dynect-test/certbot-hook.sh cleanup" \
      --manual-public-ip-logging-ok \
      --preferred-challenges dns \
      certonly
