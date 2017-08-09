from boto.connection import AWSAuthConnection

class ESConnection(AWSAuthConnection):

    def __init__(self, region, **kwargs):
        super(ESConnection, self).__init__(**kwargs)
        self._set_auth_region_name(region)
        self._set_auth_service_name("es")

    def _required_auth_capability(self):
        return ['hmac-v4']

if __name__ == "__main__":

    client = ESConnection(
            region='<>',
            host='<>',
            aws_access_key_id='<>',
            aws_secret_access_key='<>', is_secure=False)

    print 'Registering Snapshot Repository'
    resp = client.make_request(method='POST',
            path='/_snapshot/weblogs-index-backups',
            data='{"type": "s3","settings": { "bucket": "<bucketname>","region": "<region>","role_arn": "<role with arn and access to the s3 bucket>"}}')
    body = resp.read()
    print body
