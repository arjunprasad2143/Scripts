#!/bin/bash -x 
AWSCLI=/usr/local/bin/aws
AWS_INSTANCE_ID=$(/usr/bin/curl http://169.254.169.254/latest/meta-data/instance-id)
EBS_VOLUME_ID=$($AWSCLI ec2 describe-volumes --filters "Name=attachment.instance-id, Values=${AWS_INSTANCE_ID}" --query "Volumes[].VolumeId" --out text)
echo $EBS_VOLUME_ID
NAME=$($AWSCLI ec2 describe-tags --filters Name=resource-id,Values=${AWS_INSTANCE_ID} --query 'Tags[?Key==`Name`].Value[]' --output text)
echo $NAME
ENVIRONMENT=$($AWSCLI ec2 describe-tags --filters Name=resource-id,Values=${AWS_INSTANCE_ID} --query 'Tags[?Key==`environment`].Value[]' --output text)
echo $ENVIRONMENT
MODULE=$($AWSCLI ec2 describe-tags --filters Name=resource-id,Values=${AWS_INSTANCE_ID} --query 'Tags[?Key==`module`].Value[]' --output text)

###Tagging#####
$AWSCLI ec2 create-tags --resources $EBS_VOLUME_ID --tags Key=Name,Value=$NAME Key=environment,Value=$ENVIRONMENT Key=module,Value=$MODULE Key=ebs-instance,Value=$NAME
