#!/bin/sh

echo "docker.io run --name $openldapTestContainer $runOptions -p 65389:389 -d $openldapTestImage"
docker.io run --name $openldapTestContainer $runOptions -p 65389:389 -d $openldapTestImage
sleep 5
