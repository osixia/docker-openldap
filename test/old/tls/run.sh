#!/bin/sh


runOptions="--dns=127.0.0.1 -v `pwd`/test/tls/ssl:/etc/ldap/ssl"
. $dir/tools/run-container.sh

cert=$(echo $dir/tls/ssl/ldap.crt)
certCN=$(openssl x509 -in $cert -subject -noout | sed -n 's/.*CN=\(.*\)\/*\(.*\)/\1/p')
addLine=$(echo $IP $certCN)

echo $addLine >> /etc/hosts
cp /etc/ldap/ldap.conf /etc/ldap/ldap.conf.old
sed -i 's,TLS_CACERT.*,TLS_CACERT '"$cert"',g' /etc/ldap/ldap.conf

sleep 5

