#!/bin/sh -e

# download cron from apt-get
LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends cron
