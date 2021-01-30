#!/bin/sh
# mkdir -p /home/azureuser/apps
wget -P /home/azureuser/ https://github.com/sohwaje/Powershell_for_azure/blob/master/extensions/hello-0.0.3-SNAPSHOT.jar
java -jar /home/azureuser/*.jar
