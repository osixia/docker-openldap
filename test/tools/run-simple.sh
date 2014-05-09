#!/bin/sh

echo "docker.io run --name $openldapTestContainer $runOptions -d $openldapTestImage"
ID=`docker.io run --name $openldapTestContainer $runOptions -d $openldapTestImage`
sleep 5

echo " --> Obtaining IP"
IP=`docker inspect $ID | grep IPAddress | sed -e 's/.*: "//; s/".*//'`
if [ "$IP" = "" ]; then
	abort "Unable to obtain container IP"
	exit 1
else
  echo " -->" $IP
fi
