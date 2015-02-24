#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

WITH_MMC_AGENT=${WITH_MMC_AGENT}

# Run mmc-agent
if [ "$WITH_MMC_AGENT" = true ]; then

  # Openldap is configured
  if [ -e /etc/ldap/slapd.d/docker_bootstrapped ]; then

    # mmc-agent is not already configured
    if [ ! -e /etc/mmc/agent/docker_bootstrapped ]; then
      status "configuring mmc-agent for first run"

       status () {
        echo "---> ${@}" >&2
      }

      getBaseDn () {
        IFS="."
        export IFS

        domain=$1
        init=1

        for s in $domain; do
          dc="dc=$s"
          if [ "$init" -eq 1 ]; then
            baseDn=$dc
            init=0
        else
            baseDn="$baseDn,$dc" 
          fi
        done
      }

      DOMAIN_NAME=${DOMAIN_NAME}
      WITH_MMC_AGENT=${WITH_MMC_AGENT}
      LDAP_DOMAIN=${LDAP_DOMAIN}
      LDAP_ADMIN_PWD=${LDAP_ADMIN_PWD}
      MMC_AGENT_LOGIN=${MMC_AGENT_LOGIN}
      MMC_AGENT_PASSWORD=${MMC_AGENT_PASSWORD}

      # mmc-agent config
      sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/mmc/agent/config.ini #listen on docker default network
      sed -i -e "s/login = mmc/login = $MMC_AGENT_LOGIN/" /etc/mmc/agent/config.ini
      sed -i -e "s/password = s3cr3t/password = $MMC_AGENT_PASSWORD/" /etc/mmc/agent/config.ini

      # generate ssl certificate
      rm /etc/mmc/agent/keys/cacert.pem /etc/mmc/agent/keys/localcert.pem
      /sbin/ssl-create-cert mmc /etc/mmc/agent/keys/cacert.pem /etc/mmc/agent/keys/localcert.pem

      # Get base dn from ldap domain
      getBaseDn ${LDAP_DOMAIN}

      sed -i -e "s/dc=mandriva, dc=com/$baseDn/" /etc/mmc/plugins/base.ini
      sed -i -e "s/password = secret/password = $LDAP_ADMIN_PWD/" /etc/mmc/plugins/base.ini

      mkdir /home/archives

      # Mail plugin

      sed -i -e 's/vDomainSupport = 0/vDomainSupport = 1/g' /etc/mmc/plugins/mail.ini
      sed -i -e 's/vAliasesSupport = 0/vAliasesSupport = 1/g' /etc/mmc/plugins/mail.ini
      cat /etc/mmc/agent/assets/append_to_mail.ini >> /etc/mmc/plugins/mail.ini

      touch /etc/mmc/agent/docker_bootstrapped
    else
      status "found already-configured mmc-agent"
    fi

    # Run mmc-agent
    exec /usr/sbin/mmc-agent -d

  # wait openldap config done
  else
    sleep 3s
  fi

# Do nothing but needed for runit
else 
  sleep 1d
fi