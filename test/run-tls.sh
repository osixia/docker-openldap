#!/bin/sh

docker.io run  --name openldap-test-container --dns=127.0.0.1 -v `pwd`/test/ssl:/etc/ldap/ssl -p 65389:389 -d openldap-test

cert=$(echo `pwd`/test/ssl/ldap.crt)
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

$(pwd)/test/tools/delete-container.sh
