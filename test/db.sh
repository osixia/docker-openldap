#!/bin/sh

dir=$(dirname $0)

if [ -d "$testDir" ]; then
  rm -r $testDir
fi

mkdir $testDir
mkdir $testDir/db
mkdir $testDir/config

runOptions="-e LDAP_DOMAIN=otherdomain.com -v $testDir/db:/var/lib/ldap -v $testDir/config:/etc/ldap/slapd.d"
. $dir/tools/run-container.sh
$dir/tools/delete-container.sh

runOptions="-v $testDir/db:/var/lib/ldap -v $testDir/config:/etc/ldap/slapd.d"
. $dir/tools/run-container.sh
echo "ldapsearch -x -h $IP -b dc=otherdomain,dc=com"
ldapsearch -x -h $IP -b dc=otherdomain,dc=com

rm -r $testDir
$dir/tools/delete-container.sh
