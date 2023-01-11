#!/bin/sh -e
log-helper level eq trace && set -x

PIDFILE="/var/run/syslog-ng.pid"
SYSLOGNG_OPTS=""

[ -r /etc/default/syslog-ng ] && . /etc/default/syslog-ng

exec /usr/sbin/syslog-ng --pidfile "$PIDFILE" -F $SYSLOGNG_OPTS
