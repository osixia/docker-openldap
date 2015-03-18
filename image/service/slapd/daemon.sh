#!/bin/bash -e
exec /usr/sbin/slapd -h "ldap:/// ldapi:///" -u openldap -g openldap -d -1