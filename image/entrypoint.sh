#!/bin/bash -e

LDAP_OPENLDAP_UID=${LDAP_OPENLDAP_UID:-911}
LDAP_OPENLDAP_GID=${LDAP_OPENLDAP_GID:-911}

# get current group of openldap user inside container
CUR_USER_GID=`id -g openldap || true`
CUR_USER_UID=`id -u openldap || true`

# if they don't match, adjust
if [ "$LDAP_OPENLDAP_UID" != "$CUR_USER_UID" ]; then
    usermod -o -u "$LDAP_OPENLDAP_UID" openldap
fi
if [ "$LDAP_OPENLDAP_GID" != "$CUR_USER_GID" ]; then
    groupmod -o -g "$LDAP_OPENLDAP_GID" openldap
fi

echo '
-------------------------------------
GID/UID
-------------------------------------'
echo "
User uid:    $(id -u openldap)
User gid:    $(id -g openldap)
-------------------------------------
"

exec /container/tool/run "$@"
