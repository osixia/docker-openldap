#!/bin/bash -e

FIRST_START_DONE="/etc/docker-openldap-first-start-done"

#fix file permissions
chown -R openldap:openldap /var/lib/ldap 
chown -R openldap:openldap /etc/ldap

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


  # start OpenLDAP
  slapd -h "ldapi:///" -u openldap -g openldap 

  # TLS config
  if [ "${USE_TLS,,}" == "true" ]; then

    # check certificat and key or create it
    /sbin/ssl-kit "/osixia/slapd/ssl/$SSL_CRT_FILENAME" "/osixia/slapd/ssl/$SSL_KEY_FILENAME" --ca-crt=/osixia/slapd/ssl/$SSL_CA_CRT_FILENAME --gnutls

    # create DHParamFile if not found
    [ -f /osixia/slapd/ssl/dhparam.pem ] || openssl dhparam -out /osixia/slapd/ssl/dhparam.pem 2048

    # adapt tls ldif
    sed -i "s,/osixia/slapd/ssl/ca.crt,/osixia/slapd/ssl/${SSL_CA_CRT_FILENAME},g" /osixia/slapd/tls.ldif
    sed -i "s,/osixia/slapd/ssl/ldap.crt,/osixia/slapd/ssl/${SSL_CRT_FILENAME},g" /osixia/slapd/tls.ldif
    sed -i "s,/osixia/slapd/ssl/ldap.key,/osixia/slapd/ssl/${SSL_KEY_FILENAME},g" /osixia/slapd/tls.ldif

    # set tls config
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /osixia/slapd/tls.ldif -Q 

    # add localhost route to certificate cn (need docker 1.5.0)
    cn=$(openssl x509 -in /osixia/slapd/ssl/$SSL_CRT_FILENAME -subject -noout | sed -n 's/.*CN=\(.*\)\/*\(.*\)/\1/p')
    echo "127.0.0.1 $cn" >> /etc/hosts

    # local ldap tls client config
    sed -i "s,TLS_CACERT.*,TLS_CACERT /osixia/slapd/ssl/${SSL_CA_CRT_FILENAME},g" /etc/ldap/ldap.conf
  fi

  # OpenLDAP config 
  for f in $(find /osixia/slapd/config -name \*.ldif -type f); do
    status "Processing file ${f}"
    ldapmodify -r -Y EXTERNAL -H ldapi:/// -f $f -Q 
  done

  # stop OpenLDAP
  kill -INT `cat /run/slapd/slapd.pid`

  touch $FIRST_START_DONE
fi

# fix file permissions
chown openldap:openldap -R /osixia/slapd

exit 0