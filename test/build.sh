#!/bin/sh

dir=$(dirname $0)
. $dir/tools/config.prop

docker.io build -t $openldapTestImage .
#docker.io build --no-cache=true -t $openldapTestImage .

