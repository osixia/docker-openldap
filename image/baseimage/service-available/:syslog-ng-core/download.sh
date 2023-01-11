#!/bin/sh -e

# download syslog-ng-core from apt-get
LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends syslog-ng-core
