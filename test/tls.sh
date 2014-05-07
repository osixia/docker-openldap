#!/bin/sh

dir=$(dirname $0)
. $dir/tools/config.prop

. $dir/tools/run-tls.sh
ldapsearch -x -h $certCN -p 65389 -b dc=example,dc=com -ZZ

. $dir/tools/end-tls.sh
