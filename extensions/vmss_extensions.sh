#!/bin/sh

sshpass -p'!#SI0aleldj*)' scp -P 16215 -o StrictHostKeyChecking=no /home/sigongweb/jar/api/*.jar /home/sigongweb/apps/api
java -jar /home/sigongweb/apps/api/*.jar
