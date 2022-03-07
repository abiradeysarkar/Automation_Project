#!/bin/bash
apache2Installed=$(apache2 -v | grep -i apache)
s3_bucket=upgrad-abira


sudo apt update -y
#Check if the apache2 is installed or not

echo $apache2Installed
apacheOutput=$apache2Installed

if [ ! -z "$apache2Installed" ]; then
	echo -e '\e[1;35m\nApache2 is already installed in your system'
else
	sudo apt install apache2 -y
	echo -e '\e[1;35m\nApache2 is installed now'
fi

# Checking apache2 service status

service apache2 status

# Enabling apache2 service for every reboot
sudo systemctl enable apache2.service
echo -e '\e[1;36mApache service is enabled\e[1;m'

# .tar all the log files and copy it to /tmp/

filename=Abira-httpd-logs-$(date '+%d%m%Y-%H%M%S').tar.gz
filePath=/tmp/${filename}
tar -czvf $filePath /var/log/apache2/*.log
echo -e '\e[1;35m\nThe .tar file is created and copied to /tmp/ directory\e[1;m'

#Check aws cli is installed or not, if yes copy the logs zip file to s3

aws s3 \
cp $filePath \
s3://${s3_bucket}/${filename}
echo -e '\e[1;32m\nSuccessfully .tar file is uploaded into s3 bucket\e[1;m'
echo $filename is uploaded to s3 bucket: $s3_bucket
