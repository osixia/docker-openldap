#!/bin/bash -e
exec /usr/sbin/slapd -h "ldap:///" -u openldap -g openldap -d -1