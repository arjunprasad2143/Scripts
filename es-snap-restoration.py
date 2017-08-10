#!/usr/bin/python -w
import boto
import argparse
from boto.connection import AWSAuthConnection

class ESConnection(AWSAuthConnection):
    def __init__(self, region, **kwargs):
        super(ESConnection, self).__init__(**kwargs)
        self._set_auth_region_name(region)
        self._set_auth_service_name("es")

    def _required_auth_capability(self):
        return ['hmac-v4']
def client_connection(ES_ENDPOINT):
    client = ESConnection(region='<Region>',
            host=ES_ENDPOINT,
            aws_access_key_id='XXXXXX’',
            aws_secret_access_key='XXXXXX', is_secure=False)
    return client

def snap_restore(ES_ENDPOINT,SNAPSHOT_PATH):
    client = client_connection(ES_ENDPOINT)
    print "Delete the all the indices..."
    resp = client.make_request(method='DELETE', path='/_all')
    body = resp.read()
    print body
    print "Restore the snapshot: " + SNAPSHOT_PATH
    RESTORE_PATH = SNAPSHOT_PATH + "/_restore"
    resp = client.make_request(method='POST', path=RESTORE_PATH,
    data='{"indices": "<INDEX NAME>","ignore_unavailable": false,"include_global_state": false}')
    body = resp.read()
    print body

def snap_status(ES_ENDPOINT,SNAPSHOT_PATH):
    client = client_connection(ES_ENDPOINT)
    resp = client.make_request(method='GET', path=SNAPSHOT_PATH)
    body = resp.read()
    print body

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description='To take the snapshot of the ES domains and check of the status')
    arg_parser.add_argument('-e','--endpoint', help='The Endpoint of the ES domain', required=True)
    arg_parser.add_argument('-n','--name', help='The snapshot name (the path of the snapdhot would always - /_snapshot/weblogs-index-backups/', required=True)
    arg_parser.add_argument('-a', '--action', help='Specify the action - restore to perfrom the restoration and status to check the status of the restoration', required=True)
    args = arg_parser.parse_args()
    ES_ENDPOINT = args.endpoint
    SNAPSHOT_NAME = args.name
    SNAPSHOT_ACTION = args.action
    SNAPSHOT_PATH = "/_snapshot/weblogs-index-backups/" + SNAPSHOT_NAME
    if SNAPSHOT_ACTION == "restore":
        snap_restore(ES_ENDPOINT,SNAPSHOT_PATH)
    elif SNAPSHOT_ACTION == "status":
        snap_status(ES_ENDPOINT,SNAPSHOT_PATH)

