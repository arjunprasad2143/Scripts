import csv
import sys
import boto3
from datetime import datetime, timedelta, date
import pytz
import re
from collections import defaultdict
import argparse


def ec2_connect_client(region):
    """
    Connects to EC2, returns a connection object
    """
    try:
        ec = boto3.client('ec2', region_name=region, aws_access_key_id='<>',
                          aws_secret_access_key='<>')
        print ec
    except Exception, e:
        sys.stderr.write('Could not connect to region: %s. Exception: %s\n' % (region, e))
        ec = None
    return ec


def ec2_connect_resource(region):
    """
    Connects to EC2, returns a connection object
    """
    try:
        ec = boto3.resource('ec2', region_name=region, aws_access_key_id='<>',
                            aws_secret_access_key='<>')
        print ec
    except Exception, e:
        sys.stderr.write('Could not connect to region: %s. Exception: %s\n' % (region, e))
        ec = None
    return ec


def ec2_connect_client(region):
    """
    Connects to EC2, returns a connection object
    """
    try:
        ec = boto3.client('ec2', region_name=region, aws_access_key_id='<>',
                          aws_secret_access_key='<>')
        print ec
    except Exception, e:
        sys.stderr.write('Could not connect to region: %s. Exception: %s\n' % (region, e))
        ec = None
    return ec


def ami_creation():
    # Define the variables
    valid = {'yes': True, 'y': True,
             'no': False, 'n': False}
    options = {'yes': True, 'y': True,
               'no': False, 'n': False}
    goahead = False
    goahead1 = False
    retention_days = 7
    instance_name = []
    region = '<region>'

    # connect ec2 resouce using client method for AMI creation
    ec_client = ec2_connect_client(region)
    if not ec_client:
        sys.stderr.write('Could not connect to region: %s. Skipping\n' % region)
        sys.exit(1)

    # connect ec2 resouce using resource method
    ec = ec2_connect_resource(region)
    if not ec:
        sys.stderr.write('Could not connect to region: %s. Skipping\n' % region)
        sys.exit(1)

    instance_list = ['<Instance Name>']
    for list in instance_list:
        for instance in ec.instances.all():
            instance_name = [ tags.get('Value')  for tags in instance.tags if tags['Key'] == 'Name' ]
            id = instance.id
    # Check the user entered name is in the instance list
            if list in instance_name:
                sys.stdout.write("Instance has been verified:- Name - %s, id - %s\n" % (list, id))
        # Get a confirmation from user to continue ami creation process
                choice = raw_input("Do you want to continue with AMI creation [y/n]").lower()
                if choice in valid.keys():
                    if valid[choice]:
                        goahead = True
                if goahead:
            # Create a variable for AMI NAME
                    date_obj = datetime.today()
                    date_str = date_obj.strftime('%Y-%m-%d-%H-%M-%S')
                    name = "Created for instance " + id + " at " + date_str
                    image = ec_client.create_image(
                    InstanceId=id,
                    Name=name,
                    NoReboot=True

                    )
                else:
                    sys.stdout.write("Selected option to discontinue the AMI creation process. Exit from script")
                    sys.exit(0)
                image_id = str(image['ImageId'])
                sys.stdout.write(
                "AMI Creation in progress, AMI ID - %s\nNote : Default retention period is 7 days\n" % (image_id))
                reponse = ec.create_tags(
                    Resources=[
                        image_id,
                    ],
                    Tags=[
                        {'Key': 'Name', 'Value': list},
                    ]
                )
                print reponse

if __name__ == '__main__':
    ami_creation()
