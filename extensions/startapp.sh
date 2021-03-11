wget -P -O /tmp/app.jar https://github.com/sohwaje/Powershell_for_azure/raw/master/extensions/hello-0.0.3-SNAPSHOT.jar
cd /tmp && nohup java -jar app.jar &
