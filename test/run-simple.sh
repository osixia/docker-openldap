#!/bin/sh

dir=$(dirname $0)
. $dir/tools/config.prop

docker.io run --name $openldapTestContainer -p 65389:389 -d $openldapTestImage
sleep 5
ldapsearch -x -h localhost -p 65389 -b dc=example,dc=com

$dir/tools/delete-container.sh
