import boto3
import argparse
import sys


class LetsencryptAwsUpdater():

    apiClient = boto3.client("route53")
    domain = None
    validation = None
    acmeDomainPrefix = "_acme-challenge"

    def __init__(self, domain: str, validation: str):
        self.domain = domain
        self.validation = validation


    def _perform(self, action: str):
        zoneId = self._findZoneIdForDomain(self.domain)
        print(zoneId)
        print("{0}.{1}".format(self.acmeDomainPrefix, self.domain))
        # do the actual change
        try:
            response = self.apiClient.change_resource_record_sets(
            HostedZoneId=zoneId,
            ChangeBatch= {
                'Comment': 'certbot-dns-route53 certificate validation auth',
                'Changes': [
                    {
                     'Action': action,
                     'ResourceRecordSet': {
                         'Name': "{0}.{1}".format(self.acmeDomainPrefix, self.domain),
                         'Type': 'TXT',
                         'TTL': 300,
                         'ResourceRecords': [{'Value': '"{0}"'.format(self.validation)}]
                    }
                }]
            })
        except Exception as e:
            print(e)
            sys.exit(1)

    def auth(self):
        self._perform('UPSERT')

    def cleanup(self):
        self._perform('DELETE')

    def _findZoneIdForDomain(self, domain):
        paginator = self.apiClient.get_paginator("list_hosted_zones")
        zones = []
        target_labels = domain.rstrip(".").split(".")
        for page in paginator.paginate():
            for zone in page["HostedZones"]:
                if zone["Config"]["PrivateZone"]:
                    continue

                candidate_labels = zone["Name"].rstrip(".").split(".")
                if candidate_labels == target_labels[-len(candidate_labels):]:
                    zones.append((zone["Name"], zone["Id"]))

        if not zones:
            raise Exception(
                "Unable to find a Route53 hosted zone for {0}".format(domain)
            )

        # Order the zones that are suffixes for our desired to domain by
        # length, this puts them in an order like:
        # ["foo.bar.baz.com", "bar.baz.com", "baz.com", "com"]
        # And then we choose the first one, which will be the most specific.
        zones.sort(key=lambda z: len(z[0]), reverse=True)
        return zones[0][1]


parser = argparse.ArgumentParser()
parser.add_argument(
    "action",
    help="Action to call",
    type=str
)

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

updater = LetsencryptAwsUpdater(arguments.domain, arguments.validation)

if arguments.action == 'auth':
    updater.auth()
elif arguments.action == 'cleanup':
    updater.cleanup()

sys.exit(0)
