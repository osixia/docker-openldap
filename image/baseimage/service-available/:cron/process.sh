#!/bin/sh -e
log-helper level eq trace && set -x

exec /usr/sbin/cron -f
