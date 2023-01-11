#!/bin/sh -e
log-helper level eq trace && set -x

# prevent NUMBER OF HARD LINKS > 1 error
# https://github.com/phusion/baseimage-docker/issues/198
touch /etc/crontab /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.monthly /etc/cron.weekly

find /etc/cron.d/ -exec touch {} \;
find /etc/cron.daily/ -exec touch {} \;
find /etc/cron.hourly/ -exec touch {} \;
find /etc/cron.monthly/ -exec touch {} \;
find /etc/cron.weekly/ -exec touch {} \;
