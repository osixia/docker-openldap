#!/bin/bash -e

FIRST_START_DONE="/etc/docker-openldap-first-start-done"

#fix file permissions
chown -R openldap:openldap /var/lib/ldap 
chown -R openldap:openldap /etc/ldap

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  function get_base_dn(){
    BASE_DN=""
    IFS='.' read -ra BASE_DN_TABLE <<< "$LDAP_DOMAIN"
    for i in "${BASE_DN_TABLE[@]}"; do
      EXT="dc=$i,"
      BASE_DN=$BASE_DN$EXT
    done

    BASE_DN=${BASE_DN::-1}
  }

  function is_new_schema(){
    local COUNT=$(ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config cn | grep -c $1)
    if [ "$COUNT" -eq 0 ]; then
      echo 1
    else
      echo 0
    fi
  }

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

    # start OpenLDAP
    slapd -h "ldapi:///" -u openldap -g openldap

    get_base_dn 
    sed -i "s|dc=example,dc=org|$BASE_DN|g" /osixia/slapd/security.ldif

    ldapmodify -Y EXTERNAL -Q -H ldapi:/// -f /osixia/slapd/security.ldif

  else

    # start OpenLDAP
    slapd -h "ldapi:///" -u openldap -g openldap

  fi


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

    ldapmodify -Y EXTERNAL -Q -H ldapi:/// -f /osixia/slapd/tls.ldif

    # add localhost route to certificate cn (need docker 1.5.0)
    cn=$(openssl x509 -in /osixia/slapd/ssl/$SSL_CRT_FILENAME -subject -noout | sed -n 's/.*CN=\(.*\)\/*\(.*\)/\1/p')
    echo "127.0.0.1 $cn" >> /etc/hosts

    # local ldap tls client config
    sed -i "s,TLS_CACERT.*,TLS_CACERT /osixia/slapd/ssl/${SSL_CA_CRT_FILENAME},g" /etc/ldap/ldap.conf
  fi

  # add ppolicy schema if not already exists
  ADD_PPOLICY=$(is_new_schema ppolicy)
  if [ "$ADD_PPOLICY" -eq 1 ]; then
    ldapadd -c -Y EXTERNAL -Q -H ldapi:/// -f /etc/ldap/schema/ppolicy.ldif
  fi

  # convert  schemas to ldif
  SCHEMAS=""
  for f in $(find /osixia/slapd/schema -name \*.schema -type f); do
    SCHEMAS="$SCHEMAS ${f}"
  done
  /osixia/slapd/schema-to-ldif.sh "$SCHEMAS"

  for f in $(find /osixia/slapd/schema -name \*.ldif -type f); do
    echo "Processing file ${f}"
    # add schema if not already exists
    SCHEMA=$(basename "${f}" .ldif)
    ADD_SCHEMA=$(is_new_schema $SCHEMA)
    if [ "$ADD_SCHEMA" -eq 1 ]; then
      echo "add schema ${SCHEMA}"
      ldapadd -c -Y EXTERNAL -Q -H ldapi:/// -f $f
    else
      echo "schema ${f} already exists"
    fi

  done

  # OpenLDAP config 
  for f in $(find /osixia/slapd/config -name \*.ldif -type f); do
    echo "Processing file ${f}"
    ldapmodify -Y EXTERNAL -Q -H ldapi:/// -f $f
  done

  # stop OpenLDAP
  kill -INT `cat /run/slapd/slapd.pid`

  touch $FIRST_START_DONE
fi

# fix file permissions
chown openldap:openldap -R /osixia/slapd

exit 0