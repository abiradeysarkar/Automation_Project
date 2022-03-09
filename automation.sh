#!/bin/bash
apache2Installed=$(apache2 -v | grep -i apache)
s3_bucket=upgrad-abira
name=Abira

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

filename=${name}-httpd-logs-$(date '+%d%m%Y-%H%M%S').tar.gz
filePath=/tmp/${filename}
tar -czvf $filePath /var/log/apache2/*.log
echo -e '\e[1;35m\nThe .tar file is created and copied to /tmp/ directory\e[1;m'

#Copy the logs zip file to s3 using aws cli

aws s3 \
cp $filePath \
s3://${s3_bucket}/${filename}
echo -e '\e[1;32m\nSuccessfully .tar file is uploaded into s3 bucket\e[1;m'
echo $filename is uploaded to s3 bucket: $s3_bucket

#Creating a inventory.html file, if it does not exists

file=/var/www/html/inventory.html
bold=$(tput bold)
normal=$(tput sgr0)
if [ ! -e "$file" ] ; then
	touch "$file"
	echo -e '\e[1;32minventory.html file created successfully\e[1;m'
	echo -e "${bold}Log type \tTime Created \t\tType \tSize${normal}" >> $file

fi
if [ ! -w "$file" ] ; then
	echo cannot write to $file
	exit 1
fi

# Entry data on the inventory file

logType=httpd-logs
timeCreated=$(date '+%d%m%Y-%H%M%S')
fileExtension=${filename%.*}
fileType=${fileExtension#*.}
fileSize=$(du -sh $filePath | awk '{print  $1}')
inputFile="$logType \t$timeCreated \t$fileType \t$fileSize"
echo -e "$inputFile" >> $file

# check the automation file is present or not on /etc/cron.d, if not create a automation file to add the cron job schedule everyday

cronfile=/etc/cron.d/automation
if [ ! -e "$cronfile" ] ; then
	touch "$cronfile"
	echo "0 12 * * * root /root/Automation_Project/automation.sh" >> $cronfile
	echo -e '\e[1;35mautomation file on /etc/cron.d/ created successfully\e[1;m'
fi
