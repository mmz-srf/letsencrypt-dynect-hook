#!/usr/bin/env python3

import sys
import os
import argparse

from dynect.DynectDNS import DynectRest


class LetsencryptDynectUpdater (object):

	customer_name = os.environ['CERTBOT_CUSTOMER_NAME']
	api_key = os.environ['CERTBOT_API_KEY']
	api_pass = os.environ['CERTBOT_API_PASS']
	challengeSubdomain = '_acme_challenge'
	rest_client = DynectRest()
	fqdn = None
	domain = None
	validation = None

	def __init__(self, domain, validation):
		self.domain = domain
		self.validation = validation
		self.fqdn = '{}.{}'.format(self.challengeSubdomain, self.domain)

	def login(self):
		arguments = {
			'customer_name': self.customer_name,
			'user_name': self.api_key,  
			'password': self.api_pass,
		}

		response = self.rest_client.execute('/Session/', 'POST', arguments)
		if response['status'] != 'success':
			print("Incorrect credentials")
			sys.exit(1)

	def deleteValidationRecord(self):
		return True

	def addValidationRecord(self):
		arguments = {
			'rdata': {'txtdata': self.validation},
			'ttl': 5
		}
		response = self.rest_client.execute('/TXTRecord/{}/{}/'.format(self.domain, self.fqdn), 'POST', arguments)
		if response['status'] != 'success':
			print('Adding txt record failed')
			sys.exit(1)

	def publish(self):	
		arguments = {
			'publish': 1
		}
		response = self.rest_client.execute('/Zone/{}/'.format(self.domain), 'PUT', arguments)
		if response['status'] != 'success':
			print('Adding txt record failed')
			sys.exit(1)

	def logout(self):
		self.rest_client.execute('/Session/', 'DELETE')


# arguments
parser = argparse.ArgumentParser()
parser.add_argument(
    "domain",
    help="Domain to update.",
    type=str
)
parser.add_argument(
    "validation",
    help="Validation string to update",
    type=str
)
arguments = parser.parse_args()

# update
updater = LetsencryptDynectUpdater(arguments.domain, arguments.validation)
updater.login()
updater.deleteValidationRecord()
updater.addValidationRecord()
updater.publish()
updater.logout()

