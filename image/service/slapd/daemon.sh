#!/bin/bash -e

# Reduce maximum number of number of open file descriptors to 1024
# otherwise slapd consumes two orders of magnitude more of RAM
# see https://github.com/docker/docker/issues/8231
ulimit -n 1024

# stop OpenLDAP
SLAPD_PID=$(cat /run/slapd/slapd.pid)
echo "Kill slapd, pid: $SLAPD_PID"
kill -INT $SLAPD_PID
echo "ok"

sleep 2

exec /usr/sbin/slapd -h "ldap://$HOSTNAME ldaps://$HOSTNAME ldapi:///" -u openldap -g openldap -d $LDAP_LOG_LEVEL
