#!/bin/sh -e

mkdir -p /var/lib/syslog-ng
rm -f /etc/default/syslog-ng

touch /var/log/syslog
chmod u=rw,g=r,o= /var/log/syslog
rm -f /etc/syslog-ng/syslog-ng.conf
