#!/bin/bash -x

user_name=$1
user_group=$2
public_key=$3
age=$4
  if [ ${age} -eq "-1" ] ; then
     user_age='-1'
     echo "User account will never expire"
  else
     user_age=`date +%Y-%m-%d -d "+${age} days"`
     echo "User account expires in ${user_age}days " 
  fi
#user_age=`date +%Y-%m-%d -d "+${age} days"`
shift 4

/bin/egrep "^${user_name}" /etc/passwd >/dev/null
        if [ $? -eq "0" ]
        then
            echo "${user_name} exists. Removing user"
            sudo userdel -f ${user_name}
	    sudo rm -rf /home/${user_name}
        fi

sudo useradd -m -s /bin/bash -g  ${user_group}  ${user_name}
sudo mkdir -p /home/${user_name}/.ssh/
  if [ $? -eq 0 ] ; then
     sudo touch /home/${user_name}/.ssh/authorized_keys
     sudo chmod 777 /home/${user_name}/.ssh/authorized_keys
     sudo echo "${public_key}" > /home/${user_name}/.ssh/authorized_keys
     sudo chmod 600 /home/${user_name}/.ssh/authorized_keys
     sudo chown -R ${user_name}:${user_group} /home/${user_name}/
     sudo cp /home/bbadmin/.bashrc /home/${user_name}/
  else
     echo "Failed to add a user!"
  fi
  if [ $? -eq 0 ] ; then
     echo "User has been added to system!"
  else
     echo "Failed to add a user!" 
  fi

if [ ${user_group} == "admin" ]; then
  if [ -f "/etc/sudoers.tmp" ]; then
  echo "Visudo file is open in the system. Please close the file and run the job again"  
  exit 1
  fi
sudo touch /etc/sudoers.tmp
sudo cp /etc/sudoers /tmp/sudoers.new
sudo chmod 777 /tmp/sudoers.new
  sudo echo  "${user_name} ALL= NOPASSWD: /bin/su - admin" >> /tmp/sudoers.new
sudo chmod 0440 /tmp/sudoers.new
sudo visudo -c -f /tmp/sudoers.new
  if [ "$?" -eq "0" ]; then
sudo cp /tmp/sudoers.new /etc/sudoers
  else 
  echo "There is some error in the visudo syntax.Check the log file for more details"
  fi
sudo rm /etc/sudoers.tmp
fi

sudo chage -E ${user_age} ${user_name}
  if [ $? -eq 0 ] ; then
     echo "User access will be disbled in ${age} days"
  else
     echo "Failed to add a user age!" 
  fi
