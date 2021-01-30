#!/bin/sh
mkdir -p /home/azureuser/apps
wget -P /home/azureuser/apps https://github.com/sohwaje/Powershell_for_azure/blob/master/extensions/hello-0.0.3-SNAPSHOT.jar
java -jar /home/sigongweb/apps/*.jar
