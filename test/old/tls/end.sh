#!/bin/sh

sed -i '/'"$addLine"'/d' /etc/hosts
cp /etc/ldap/ldap.conf.old /etc/ldap/ldap.conf
rm /etc/ldap/ldap.conf.old

$dir/tools/delete-container.sh
