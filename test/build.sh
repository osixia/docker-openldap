#!/bin/sh

dir=$(dirname $0)
. $dir/tools/config.prop

sudo docker.io build -t $openldapTestImage .
#sudo docker.io build --no-cache=true -t openldap-test .

