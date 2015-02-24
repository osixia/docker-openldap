#!/bin/bash -e

FIRST_START_DONE="/etc/docker-openldap-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # database is uninitialized
  if [ -z "$(ls -A /var/lib/ldap)" ]; then

    cat <<EOF | debconf-set-selections
slapd slapd/internal/generated_adminpw password ${LDAP_ADMIN_PASSWORD}
slapd slapd/internal/adminpw password ${LDAP_ADMIN_PASSWORD}
slapd slapd/password2 password ${LDAP_ADMIN_PASSWORD}
slapd slapd/password1 password ${LDAP_ADMIN_PASSWORD}
slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
slapd slapd/domain string ${LDAP_DOMAIN}
slapd shared/organization string ${LDAP_ORGANISATION}
slapd slapd/backend string HDB
slapd slapd/purge_database boolean true
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/no_configuration boolean false
slapd slapd/dump_database select when needed
EOF

    dpkg-reconfigure -f noninteractive slapd
  fi

  #fix file permissions
  chown -R openldap:openldap /var/lib/ldap 
  chown -R openldap:openldap /etc/ldap

  # start OpenLDAP
  slapd -h "ldapi:///" -u openldap -g openldap 

  # TLS config
  if [ "${USE_TLS,,}" == "true" ]; then

    # check certificat and key or create it
    /sbin/ssl-kit "/osixia/slapd/$SSL_CRT_FILENAME" "/osixia/slapd/$SSL_KEY_FILENAME" --ca-crt=/osixia/slapd/$SSL_CA_CRT_FILENAME --gnutls
    chown openldap:openldap -R /osixia/slapd


  fi

  # stop OpenLDAP
  kill -INT `cat /run/slapd/slapd.pid`

  touch $FIRST_START_DONE
fi

exit 0




#!/bin/sh

set -eu

status () {
  echo "---> ${@}" >&2
}


set -x
: LDAP_ADMIN_PWD=${LDAP_ADMIN_PWD}
: LDAP_DOMAIN=${LDAP_DOMAIN}
: LDAP_ORGANISATION=${LDAP_ORGANISATION}
: DOMAIN_NAME=${DOMAIN_NAME}


############ Base config ############
if [ ! -e /var/lib/ldap/docker_bootstrapped ]; then
  status "configuring slapd database"





  touch /var/lib/ldap/docker_bootstrapped

else
  status "slapd database found"
fi


############ Custom config ############
if [ ! -e /etc/ldap/slapd.d/docker_bootstrapped ]; then
  status "Custom config"

  slapd -h "ldapi:///" -u openldap -g openldap 
  chown -R openldap:openldap /etc/ldap 

  if [ "$WITH_MMC_AGENT" = true ]; then

    # Convert needed mmc ldap schema to ldif
    mkdir -p /etc/ldap/schema/converted
    slaptest -f /etc/mmc/agent/assets/convert_to_ldif -F /etc/ldap/schema/converted

    sed -i -e 's/^dn:.*$/dn: cn=mmc,cn=schema,cn=config/; s/^cn:.*$/cn: mmc/; /^structuralObjectClass:.*$/d; /^entryUUID:.*$/d; /^creatorsName:.*$/d; /^createTimestamp:.*$/d; /^entryCSN:.*$/d; /^modifiersName:.*$/d; /^modifyTimestamp:.*$/d' /etc/ldap/schema/converted/cn\=config/cn\=schema/cn=\{4\}mmc.ldif
  
    sed -i -e 's/^dn:.*$/dn: cn=mail,cn=schema,cn=config/; s/^cn:.*$/cn: mail/; /^structuralObjectClass:.*$/d; /^entryUUID:.*$/d; /^creatorsName:.*$/d; /^createTimestamp:.*$/d; /^entryCSN:.*$/d; /^modifiersName:.*$/d; /^modifyTimestamp:.*$/d' /etc/ldap/schema/converted/cn\=config/cn\=schema/cn=\{5\}mail.ldif

    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/converted/cn\=config/cn\=schema/cn=\{4\}mmc.ldif -Q 
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/converted/cn\=config/cn\=schema/cn=\{5\}mail.ldif -Q 

  fi

  # TLS
  if [ -e /etc/ldap/ssl/ldap.crt ] && [ -e /etc/ldap/ssl/ldap.key ] && [ -e /etc/ldap/ssl/ca.crt ]; then
    status "certificates found"

  else

    # generate default tls certificate
    export SSL_SLAPD_COMMON_NAME="$DOMAIN_NAME"
    export SSL_SLAPD_ORGANIZATION="${LDAP_ORGANISATION}"

    /sbin/ssl-gnutls-create-signed-cert slapd /etc/ldap/ssl/ldap.crt /etc/ldap/ssl/ldap.key
    ln -s /etc/ssl/certs/docker_baseimage_gnutls_cacert.pem /etc/ldap/ssl/ca.crt

  fi

  # Fix permission on certificates
  chown openldap:openldap -R /etc/ldap/ssl
  chmod 600 /etc/ldap/ssl/ldap.key

  # ldap client config
  sed -i 's,TLS_CACERT.*,TLS_CACERT /etc/ldap/ssl/ca.crt,g' /etc/ldap/ldap.conf
 
  # create DHParamFile if not found
  [ -f /etc/ldap/ssl/dhparam.pem ] || openssl dhparam -out /etc/ldap/ssl/dhparam.pem 2048

  ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/ldap/config/modify/auto/tls.ldif -Q 

  # add fake dnsmasq route to certificate cn
  cn=$(openssl x509 -in /etc/ldap/ssl/ldap.crt -subject -noout | sed -n 's/.*CN=\(.*\)\/*\(.*\)/\1/p')
  /sbin/dns-add-host 127.0.0.1 $cn

  # Replication
  # todo :)

  # Add config
  for f in $(find /etc/ldap/config/add -maxdepth 1 -name \*.ldif -type f); do
    status "Processing file ${f}"
    ldapadd -Y EXTERNAL -H ldapi:/// -f $f -Q 
  done

  # Modify config 
  for f in $(find /etc/ldap/config/modify -maxdepth 1 -name \*.ldif -type f); do
    status "Processing file ${f}"
    ldapmodify -Y EXTERNAL -H ldapi:/// -f $f -Q 
  done

  kill -INT `cat /run/slapd/slapd.pid`

  touch /etc/ldap/slapd.d/docker_bootstrapped

else
  status "found already-configured slapd"
fi

status "starting slapd on default port 389"
set -x

