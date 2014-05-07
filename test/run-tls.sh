#!/bin/sh

dir=$(dirname $0)
. $dir/tools/config.prop

docker.io run  --name $openldapTestContainer --dns=127.0.0.1 -v `pwd`/test/ssl:/etc/ldap/ssl -p 65389:389 -d $openldapTestImage

cert=$(echo $dir/ssl/ldap.crt)
certCN=$(openssl x509 -in $cert -subject -noout | sed -n 's/.*CN=\(.*\)\/*\(.*\)/\1/p')
addLine=$(echo "127.0.0.1" $certCN)

echo $addLine >> /etc/hosts
cp /etc/ldap/ldap.conf /etc/ldap/ldap.conf.old
sed -i 's,TLS_CACERT.*,TLS_CACERT '"$cert"',g' /etc/ldap/ldap.conf


sleep 5
ldapsearch -x -h $certCN -p 65389 -b dc=example,dc=com -ZZ

sed -i '/'"$addLine"'/d' /etc/hosts
cp /etc/ldap/ldap.conf.old /etc/ldap/ldap.conf
rm /etc/ldap/ldap.conf.old

$dir/tools/delete-container.sh
