#!/bin/sh

dir=$(dirname $0)
. $dir/tools/run-container.sh

echo "ldapsearch -x -h $IP -b dc=example,dc=com"
sleep 30
ldapsearch -x -h $IP -b dc=example,dc=com

$dir/tools/delete-container.sh
