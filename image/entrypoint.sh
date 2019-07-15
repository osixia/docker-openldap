#!/bin/bash -e
##!/usr/bin/env bash
##!/bin/bash

PUID=${PUID:-911}
PGID=${PGID:-911}

## ref: https://github.com/sudo-bmitch/jenkins-docker/blob/master/entrypoint.sh
# get current group of openldap user inside container
#CUR_USER_GID=`getent group openldap | cut -f3 -d: || true`
#CUR_USER_UID=`id openldap | cut -f1 -d' ' | cut -f2 -d= | cut -f1 -d"(" || true`

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

#exec /init
#echo "\$@=${@}"
#/container/tool/run "$@"
exec /container/tool/run "$@"
