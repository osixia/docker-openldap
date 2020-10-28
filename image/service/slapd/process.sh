#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# Reduce maximum number of number of open file descriptors to 1024
# otherwise slapd consumes two orders of magnitude more of RAM
# see https://github.com/docker/docker/issues/8231
ulimit -n $LDAP_NOFILE

# Call hostname to determine the fully qualified domain name. We want OpenLDAP to listen
# to the named host for the ldap:// and ldaps:// protocols.
# FQDN="$(/bin/hostname --fqdn)"
# HOST_PARAM="ldap://$FQDN:$LDAP_PORT ldaps://$FQDN:$LDAPS_PORT"
# HOST_PARAM="ldap://$HOSTNAME:$LDAP_PORT ldaps://$HOSTNAME:$LDAPS_PORT"

# NOTE: $HOST_PARAM must be consistent with olcServerID, so we should only use $HOSTNAME here, no $FQDN, no port. This
# is more friendly with the setup in k8s, as in k8s the FQDN will be the cluster domain which normally you don't want.
HOST_PARAM="ldap://$HOSTNAME ldaps://$HOSTNAME"
exec /usr/sbin/slapd -h "$HOST_PARAM ldapi:///" -u openldap -g openldap -d "$LDAP_LOG_LEVEL"
