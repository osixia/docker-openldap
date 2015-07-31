#!/bin/bash -e

# Usage :
# ./add-readonly-user.sh LDAP_DOMAIN LDAP_ADMIN_PASSWORD LDAP_READONLY_USERNAME LDAP_READONLY_PASSWORD

# Example :
# ./add-readonly-user.sh example.org admin readonly readonly-password

LDAP_DOMAIN=$1
LDAP_ADMIN_PASSWORD=$2
LDAP_READONLY_USERNAME=$3
LDAP_READONLY_PASSWORD=$4

function get_ldap_base_dn() {
  LDAP_BASE_DN=""
  IFS='.' read -ra LDAP_BASE_DN_TABLE <<< "$LDAP_DOMAIN"
  for i in "${LDAP_BASE_DN_TABLE[@]}"; do
    EXT="dc=$i,"
    LDAP_BASE_DN=$LDAP_BASE_DN$EXT
  done

  LDAP_BASE_DN=${LDAP_BASE_DN::-1}
}

get_ldap_base_dn
LDAP_READONLY_PASSWORD_ENCRYPTED=$(slappasswd -s $LDAP_READONLY_PASSWORD)
sed -i "s|{{ LDAP_READONLY_USERNAME }}|${LDAP_READONLY_USERNAME}|g" /container/service/slapd/assets/config/readonly-user/readonly-user.ldif
sed -i "s|{{ LDAP_READONLY_PASSWORD_ENCRYPTED }}|${LDAP_READONLY_PASSWORD_ENCRYPTED}|g" /container/service/slapd/assets/config/readonly-user/readonly-user.ldif
sed -i "s|{{ LDAP_BASE_DN }}|${LDAP_BASE_DN}|g" /container/service/slapd/assets/config/readonly-user/readonly-user.ldif

sed -i "s|{{ LDAP_READONLY_USERNAME }}|${LDAP_READONLY_USERNAME}|g" /container/service/slapd/assets/config/readonly-user/readonly-user-acl.ldif
sed -i "s|{{ LDAP_BASE_DN }}|${LDAP_BASE_DN}|g" /container/service/slapd/assets/config/readonly-user/readonly-user-acl.ldif

ldapmodify -h localhost -p 389 -D cn=admin,$LDAP_BASE_DN -w $LDAP_ADMIN_PASSWORD -f /container/service/slapd/assets/config/readonly-user/readonly-user.ldif
ldapmodify -Y EXTERNAL -Q -H ldapi:/// -f /container/service/slapd/assets/config/readonly-user/readonly-user-acl.ldif
