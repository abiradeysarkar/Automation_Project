# Automation_Project
This repository is to automate the below process: 
 1. Installing apache2 server, archived the log files into /tmp/ directory
 2. Copy the archived tar file to s3 bucket using aws cli
 3. Push the script to Github with Tag: Automation-v0.1
 4. Create the entries each time the archived files generated into inventory.html file
 5. When the script is executed, it should create /var/www/html/inventory.html with the proper header and append detail of copied Tar file in the next line. The script should never overwrite the present content of the file.
