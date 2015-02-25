#!/bin/sh

echo "docker run --name $testContainer $runOptions -d $testImage $runCommand /sbin/my_init --enable-insecure-key"
ID=`docker run --name $testContainer $runOptions -d $testImage $runCommand /sbin/my_init --enable-insecure-key`
sleep 10

echo " --> Obtaining IP"
IP=`docker inspect -f "{{ .NetworkSettings.IPAddress }}" $ID`
if [ "$IP" = "" ]; then
	abort "Unable to obtain container IP"
	exit 1
else
  echo " -->" $IP
fi
