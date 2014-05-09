#!/bin/sh

dir=$(dirname $0)
. $dir/tools/config.prop

. $dir/tools/run-simple.sh
echo "ldapsearch -x -h $IP -b dc=example,dc=com"
ldapsearch -x -h $IP -b dc=example,dc=com

$dir/tools/delete-container.sh
