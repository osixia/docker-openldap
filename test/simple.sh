#!/bin/sh

dir=$(dirname $0)
. $dir/tools/config.prop

. $dir/tools/run-simple.sh
ldapsearch -x -h localhost -p 65389 -b dc=example,dc=com

$dir/tools/delete-container.sh
