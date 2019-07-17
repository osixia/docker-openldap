#!/bin/bash -e

PUID=${PUID:-911}
PGID=${PGID:-911}

# get current group of openldap user inside container
CUR_USER_GID=`id -g openldap || true`
CUR_USER_UID=`id -u openldap || true`

# if they don't match, adjust
if [ ! -z "$PUID" -a "$PUID" != "$CUR_USER_UID" ]; then
    usermod -o -u "$PUID" openldap
fi
if [ ! -z "$PGID" -a "$PGID" != "$CUR_USER_GID" ]; then
    groupmod -o -g "$PGID" openldap
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
