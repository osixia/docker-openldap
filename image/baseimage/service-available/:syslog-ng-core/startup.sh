#!/bin/sh -e
log-helper level eq trace && set -x

ln -sf "${CONTAINER_SERVICE_DIR}/:syslog-ng-core/assets/config/syslog_ng_default" /etc/default/syslog-ng
ln -sf "${CONTAINER_SERVICE_DIR}/:syslog-ng-core/assets/config/syslog-ng.conf" /etc/syslog-ng/syslog-ng.conf

# If /dev/log is either a named pipe or it was placed there accidentally,
# e.g. because of the issue documented at https://github.com/phusion/baseimage-docker/pull/25,
# then we remove it.
if [ ! -S /dev/log ]; then rm -f /dev/log; fi
if [ ! -S /var/lib/syslog-ng/syslog-ng.ctl ]; then rm -f /var/lib/syslog-ng/syslog-ng.ctl; fi

# determine output mode on /dev/stdout because of the issue documented at https://github.com/phusion/baseimage-docker/issues/468
if [ -p /dev/stdout ]; then
    sed -i 's/##SYSLOG_OUTPUT_MODE_DEV_STDOUT##/pipe/' /etc/syslog-ng/syslog-ng.conf
else
    sed -i 's/##SYSLOG_OUTPUT_MODE_DEV_STDOUT##/file/' /etc/syslog-ng/syslog-ng.conf
fi

# If /var/log is writable by another user logrotate will fail
/bin/chown root:root /var/log
/bin/chmod 0755 /var/log
