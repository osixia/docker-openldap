#!/bin/sh

dir=$(dirname $0)
. $dir/tools/config.prop

if [ -d "$openldapTestDir" ]; then
  rm -r $openldapTestDir
fi

mkdir $openldapTestDir
mkdir $openldapTestDir/db
mkdir $openldapTestDir/config

runOptions="-e LDAP_DOMAIN=otherdomain.com -v $openldapTestDir/db:/var/lib/ldap -v $openldapTestDir/config:/etc/ldap/slapd.d"
. $dir/tools/run-simple.sh
$dir/tools/delete-container.sh

runOptions="-v $openldapTestDir/db:/var/lib/ldap -v $openldapTestDir/config:/etc/ldap/slapd.d"
. $dir/tools/run-simple.sh
ldapsearch -x -h localhost -p 65389 -b dc=otherdomain,dc=com

rm -r $openldapTestDir
$dir/tools/delete-container.sh
