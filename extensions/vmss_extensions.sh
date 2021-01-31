#!/bin/sh
wget https://github.com/sohwaje/Powershell_for_azure/blob/master/extensions/hello-0.0.3-SNAPSHOT.jar -P /tmp
sleep 1
java -jar /tmp/hello-0.0.3-SNAPSHOT.jar
