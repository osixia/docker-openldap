#!/usr/bin/env bash
##!/bin/bash

PUID=${PUID:-911}
PGID=${PGID:-911}

groupmod -o -g "$PGID" openldap
usermod -o -u "$PUID" openldap

echo '
-------------------------------------
GID/UID
-------------------------------------'
echo "
User uid:    $(id -u openldap)
User gid:    $(id -g openldap)
-------------------------------------
"
#chown openldap:openldap /app
#chown openldap:openldap /config
#chown openldap:openldap /defaults

## fix file permissions
#chown -R openldap:openldap /var/lib/ldap
#chown -R openldap:openldap /etc/ldap
#chown -R openldap:openldap ${CONTAINER_SERVICE_DIR}/slapd

#exec /init
exec /container/tool/run "$@"
