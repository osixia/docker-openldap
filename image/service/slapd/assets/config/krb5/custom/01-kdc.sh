#!/bin/bash

# Set default values if they're not overridden by environment variables.
if [ -z ${LDAP_BASE_DN} ]; then
  LDAP_BASE_DN="{{ LDAP_BASE_DN }}"
fi
if [ -z ${KRB_REALM} ]; then
  KRB_REALM="{{ KRB_REALM }}"
fi

#
# Eeek!
#
if [ -z ${LDAP_ADMIN_PASSWORD} ]; then
  LDAP_ADMIN_PASSWORD="{{ LDAP_ADMIN_PASSWORD }}"
fi
if [ -z ${KRB_MASTER_PASSWORD} ]; then
  KRB_MASTER_PASSWORD="{{ KRB_MASTER_PASSWORD }}"
fi

#
# create KDC entries
#
coproc kdb5_ldap_util -D cn=admin,${LDAP_BASE_DN} -w ${LDAP_ADMIN_PASSWORD} -H ldapi:// create \
    -subtrees ou=users,${LDAP_BASE_DN}:ou=services,${LDAP_BASE_DN} -sscope SUB -r ${KRB_REALM}
echo ${KRB_MASTER_PASSWORD} >&${COPROC[1]}
echo ${KRB_MASTER_PASSWORD} >&${COPROC[1]}
wait

# start servers
service krb5-kdc start
service krb5-admin-server start
