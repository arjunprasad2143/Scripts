#!/bin/bash -x
AWS=/usr/local/bin/aws
admin_sg="sg-XXXXX"
fe_sg="sg-XXXXXX"
api_sg="sg-XXXXX"
reports_sg="sg-XXXXX"
cssh_sg="sg-XXXXX"

if [ ${cssh_status} == "ENABLE" ]; then
    echo $module_name
    module=(`echo ${module_name} |  tr ',' '\n'`)
    echo $module
	for NAME in ${module[@]}
	do
	  INSTANCE_ID=$(${AWS} ec2 describe-instances --filters "Name=tag:module,Values=${NAME}" --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
		for instance in ${INSTANCE_ID[@]}
	  	do
		  if [ ${NAME} == "fe" ];then
		   $AWS ec2 modify-instance-attribute --instance-id ${instance_id}  --groups ${cssh_sg} ${fe_sg}
		   echo "FE Security groups updated for instance ${instance_id}"
		  elif [ ${NAME} == "admin" ];then
		   $AWS ec2 modify-instance-attribute --instance-id ${instance_id}  --groups ${cssh_sg} ${admin_sg}
		   echo "ADMIN Security groups udpated for instance ${instance_id}"
		  elif [ ${NAME} == "api" ];then
		   $AWS ec2 modify-instance-attribute --instance-id ${instance_id}  --groups ${cssh_sg} ${api_sg}
		   echo "API Security groups udpated for instance ${instance_id}"
		  elif [ ${NAME} == "reports" ];then
		   $AWS ec2 modify-instance-attribute --instance-id ${instance_id}  --groups ${cssh_sg} ${reports_sg}
		   echo "REPORTS Security groups udpated for instance ${instance_id}"
		  else
		   echo "There is an  error. Check the module mentioned"
		   exit 1
		  fi
	        done
	   done
elif  [ ${cssh_status} == "DISABLE" ]; then
	module=(`echo ${module_name} |  tr ',' '\n'`)
    	echo $module
        for NAME in ${module[@]}
        do
          INSTANCE_ID=$(${AWS} ec2 describe-instances --filters "Name=tag:module,Values=${NAME}" --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
                for instance in ${INSTANCE_ID[@]}
                do
                if [ ${NAME} == "fe" ];then
                   $AWS ec2 modify-instance-attribute --instance-id ${instance_id}  --groups ${fe_sg}
                elif [ ${NAME} == "admin" ];then
                   $AWS ec2 modify-instance-attribute --instance-id ${instance_id}  --groups ${admin_sg}
                elif [ ${NAME} == "api" ];then
                   $AWS ec2 modify-instance-attribute --instance-id ${instance_id}  --groups ${api_sg}
                elif [ ${NAME} == "reports" ];then
                   $AWS ec2 modify-instance-attribute --instance-id ${instance_id}  --groups ${reports_sg}
                else
                   echo "There is an  error. Check the module mentioned"
		   		   exit 1
                fi
           done
	done
else
	echo "There is some error in the parameters passed. Please check"
	exit 1
fi
