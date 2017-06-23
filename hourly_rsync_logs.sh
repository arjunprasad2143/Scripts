#!/bin/bash
#Written by Rakesh P.B

#Perform the sync operation of logs from production servers to bblog server in directory structure like <MM-YYY>/<DD>/<COMPONENT>/<HOSTNAME>/<log file>
#Constant varibles

readonly SRC_DIR="<DIR>"
readonly DES_IP=<IP>
readonly REMOTE_USER="bbadmin"
readonly MONTH_YEAR_FOLDER=$(date +%m-%Y)
readonly DATE_TO=`date +%Y-%m-%d`
readonly EMAIL="<email-id>"
#Getting the Instance name & removing colons in the name if any
readonly COMPONENT_INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
readonly COMPONENT_INSTANCE_NAME="$(aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --region ap-south-1 --output text)"
echo $COMPONENT_INSTANCE_ID
echo $COMPONENT_INSTANCE_NAME
COMPONENT="$(echo "$COMPONENT_INSTANCE_NAME" | sed 's/:/-/g' | sed 's/./\U&/g')"

echo $COMPONENT
readonly DES_DIR="${MONTH_YEAR_FOLDER}/${COMPONENT}/${HOSTNAME}"

if [ -z ${COMPONENT} ]; then
    mail -s "${HOSTNAME} rsync script exection failed due to empty component" ${EMAIL}
    echo "Component variable is empty.  Exiting from script"
    exit 1
else
    echo "The script execution started on `hostname`, Component:  ${COMPONENT}"
    count=`ps -eaf | grep "rsync -avz" | wc -l`
    if [ $count -gt 1 ] ;then
        echo "`date +%d%m%Y-%T` "
        echo "Already the Rsync process is running "
    else
        echo "Rsync process is starting `date +%d%m%Y-%T` "
        ssh ${REMOTE_USER}@${DES_IP} "mkdir -p /prodlogs/${DES_DIR}"
        if [ $? -eq "0" ];then
            echo "Successfully created rsync directory : /prodlogs/${DES_DIR}"
        else 
            echo "Failed  to create  rsync directory :  /prodlogs/${DES_DIR}"
        fi
        rsync -avz -e ssh ${SRC_DIR} ${DES_IP}:/prodlogs/${DES_DIR}
        if [ $? -eq "0" ]; then
            echo "Successfully copied logs files"
        else
            echo "Failed to copied logs files"
        fi
    fi
fi
