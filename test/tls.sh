#!/bin/sh

dir=$(dirname $0)
. $dir/tools/config.prop

. $dir/tools/run-tls.sh
echo "ldapsearch -x -h $certCN -b dc=example,dc=com -ZZ"
ldapsearch -x -h $certCN -b dc=example,dc=com -ZZ

. $dir/tools/end-tls.sh
