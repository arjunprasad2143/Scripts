#!/bin/bash

readonly COMPONENT_INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

echo "instance ID is $COMPONENT_INSTANCE_ID"

readonly COMPONENT_INSTANCE_NAME="$(aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --profile bb-prod --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --region ap-south-1 --output text)"

COMPONENT="$(echo "$COMPONENT_INSTANCE_NAME" | sed 's/:/-/g' |  tr '[:lower:]' '[:upper:]')"

echo "appending $COMPONENT to welcome file"

sudo bash -c "echo "" > /etc/issue.net"
sudo bash -c "echo 'x'  > /etc/motd"
    if [ $? != "0" ]; then
      echo "Failed to update welcome script"
    else
        sudo bash -c "sed -i 's/x/######################################################################\n## COPYRIGHT\n#  2017, <>, All Rights Reserved.\n## $COMPONENT##\n######################################################################/g' /etc/motd"
        echo $?
        exit 0
    fi
