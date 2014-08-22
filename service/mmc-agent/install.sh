#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

WITH_MMC_AGENT=${WITH_MMC_AGENT}
LDAP_DOMAIN=${LDAP_DOMAIN}
LDAP_ADMIN_PWD=${LDAP_ADMIN_PWD}

if [ "$WITH_MMC_AGENT" = true ]; then

  mkdir -p /etc/ldap/schema/converted
  slaptest -f /etc/ldap/config/convert_to_ldif -F /etc/ldap/schema/converted

  sed -i -e 's/^dn:.*$/dn: cn=mmc,cn=schema,cn=config/; s/^cn:.*$/cn: mmc/; /^structuralObjectClass:.*$/d; /^entryUUID:.*$/d; /^creatorsName:.*$/d; /^createTimestamp:.*$/d; /^entryCSN:.*$/d; /^modifiersName:.*$/d; /^modifyTimestamp:.*$/d' /etc/ldap/schema/converted/cn\=config/cn\=schema/cn=\{4\}mmc.ldif
  
  sed -i -e 's/^dn:.*$/dn: cn=mail,cn=schema,cn=config/; s/^cn:.*$/cn: mail/; /^structuralObjectClass:.*$/d; /^entryUUID:.*$/d; /^creatorsName:.*$/d; /^createTimestamp:.*$/d; /^entryCSN:.*$/d; /^modifiersName:.*$/d; /^modifyTimestamp:.*$/d' /etc/ldap/schema/converted/cn\=config/cn\=schema/cn=\{5\}mail.ldif

  # Base config
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

  # Get base dn from ldap domain
  getBaseDn ${LDAP_DOMAIN}

  sed -i -e "s/dc=mandriva, dc=com/$baseDn/" /etc/mmc/plugins/base.ini
  sed -i -e "s/password = secret/password = $LDAP_ADMIN_PWD/" /etc/mmc/plugins/base.ini

  mkdir /home/archives

  # Mail plugin
  sed -i -e 's/vDomainSupport = 0/vDomainSupport = 1/g' /etc/mmc/plugins/mail.ini
  sed -i -e 's/vAliasesSupport = 0/vAliasesSupport = 1/g' /etc/mmc/plugins/mail.ini
  cat /etc/ldap/config/append_to_mail.ini >> /etc/mmc/plugins/mail.ini

fi
