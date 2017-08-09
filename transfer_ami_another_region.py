import boto3
import json
import ast

Source_Region = '<>'
Destination_Region = ',<>'
AMI_LIST = {'<Instance Name>': '<AMI-ID>'}

ec2source = boto3.client('ec2', region_name=Source_Region,aws_access_key_id='<>',aws_secret_access_key='<>')
ec2destination = boto3.client('ec2', region_name=Destination_Region,aws_access_key_id='<>',aws_secret_access_key='<>')

# Main Loop to copy AMI
for AMI_NAME, AMI_ID in AMI_LIST.iteritems():
    # Check AMI Id is available in source region
    response = ec2source.describe_images(ImageIds=[AMI_ID])
    print response
    # If AMI Id is not present in source region then skip coping
    if len(response['Images']) > 0:
        #print response
        # Copy AMI in Destination Region
        response = ec2destination.copy_image(SourceRegion=Source_Region,SourceImageId=AMI_ID,Name=AMI_NAME)

    else:
        continue
