#!/bin/sh -e

# download logrotate from apt-get
LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends logrotate
