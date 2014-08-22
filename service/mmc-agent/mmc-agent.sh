#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

WITH_MMC_AGENT=${WITH_MMC_AGENT}

if [ "$WITH_MMC_AGENT" = true ]; then

  if [ -e /etc/ldap/config/docker_bootstrapped ]; then
    exec /usr/sbin/mmc-agent -d
  else
    sleep 3s
  fi
else 
  sleep 1d
fi
