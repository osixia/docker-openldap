#!/bin/bash -e

FIRST_START_DONE="/etc/docker-openldap-first-start-done"
WAS_STARTED_WITH_TLS="/etc/ldap/slapd.d/docker-openldap-was-started-with-tls"
WAS_STARTED_WITH_REPLICATION="/etc/ldap/slapd.d/docker-openldap-was-started-with-replication"

# Reduce maximum number of number of open file descriptors to 1024
# otherwise slapd consumes two orders of magnitude more of RAM
# see https://github.com/docker/docker/issues/8231
ulimit -n 1024

#fix file permissions
chown -R openldap:openldap /var/lib/ldap
chown -R openldap:openldap /etc/ldap
chown -R openldap:openldap /osixia/service/slapd

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  function get_base_dn() {
    BASE_DN=""
    IFS='.' read -ra BASE_DN_TABLE <<< "$LDAP_DOMAIN"
    for i in "${BASE_DN_TABLE[@]}"; do
      EXT="dc=$i,"
      BASE_DN=$BASE_DN$EXT
    done

    BASE_DN=${BASE_DN::-1}
  }

  function is_new_schema() {
    local COUNT=$(ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config cn | grep -c $1)
    if [ "$COUNT" -eq 0 ]; then
      echo 1
    else
      echo 0
    fi
  }

  function check_tls_files() {

    local CA_CRT=$1
    local LDAP_CRT=$2
    local LDAP_KEY=$3

    # check certificat and key or create it
    /sbin/ssl-helper "/osixia/service/slapd/assets/ssl/$LDAP_CRT" "/osixia/service/slapd/assets/ssl/$LDAP_KEY" --ca-crt=/osixia/service/slapd/assets/ssl/$CA_CRT --gnutls

    # create DHParamFile if not found
    [ -f /osixia/service/slapd/assets/ssl/dhparam.pem ] || openssl dhparam -out /osixia/service/slapd/assets/ssl/dhparam.pem 2048

    # fix file permissions
    chown -R openldap:openldap /osixia/service/slapd
  }


  BOOTSTRAP=false

  # database and config directory are empty -> set bootstrap config
  if [ -z "$(ls -A /var/lib/ldap)" ] && [ -z "$(ls -A /etc/ldap/slapd.d)" ]; then

    BOOTSTRAP=true
    echo "database and config directory are empty"
    echo "-> set bootstrap config"

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

  elif [ -z "$(ls -A /var/lib/ldap)" ] && [ ! -z "$(ls -A /etc/ldap/slapd.d)" ]; then
    echo "Error: the database directory (/var/lib/ldap) is empty but not the config directory (/etc/ldap/slapd.d)"
    exit 1
  elif [ ! -z "$(ls -A /var/lib/ldap)" ] && [ -z "$(ls -A /etc/ldap/slapd.d)" ]; then
    echo "the config directory (/etc/ldap/slapd.d) is empty but not the database directory (/var/lib/ldap)"
    exit 1

  else
    # there is an existing database and config

    # if the config was bootstraped with TLS
    # to avoid error (#6) we check tls files
    if [ -e "$WAS_STARTED_WITH_TLS" ]; then

      . $WAS_STARTED_WITH_TLS

      check_tls_files $PREVIOUS_SSL_CA_CRT_FILENAME $PREVIOUS_SSL_CRT_FILENAME $PREVIOUS_SSL_KEY_FILENAME
    fi
  fi

  # start OpenLDAP
  echo "Starting openldap..."
  slapd -h "ldapi:///" -u openldap -g openldap
  echo "[ok]"

  # set bootstrap config part 2
  if $BOOTSTRAP; then

    # add ppolicy schema if not already exists
    ADD_PPOLICY=$(is_new_schema ppolicy)
    if [ "$ADD_PPOLICY" -eq 1 ]; then
      ldapadd -c -Y EXTERNAL -Q -H ldapi:/// -f /etc/ldap/schema/ppolicy.ldif
    fi

    # convert schemas to ldif
    SCHEMAS=""
    for f in $(find /osixia/service/slapd/assets/config/bootstrap/schema -name \*.schema -type f); do
      SCHEMAS="$SCHEMAS ${f}"
    done
    /osixia/service/slapd/assets/schema-to-ldif.sh "$SCHEMAS"

    # add schemas
    for f in $(find /osixia/service/slapd/assets/config/bootstrap/schema -name \*.ldif -type f); do
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

    # set config password
    CONFIG_PASSWORD_ENCRYPTED=$(slappasswd -s $LDAP_CONFIG_PASSWORD)
    sed -i "s|{{ CONFIG_PASSWORD_ENCRYPTED }}|$CONFIG_PASSWORD_ENCRYPTED|g" /osixia/service/slapd/assets/config/bootstrap/ldif/config-password.ldif

    # adapt security config file
    get_base_dn
    sed -i "s|dc=example,dc=org|$BASE_DN|g" /osixia/service/slapd/assets/config/bootstrap/ldif/security.ldif

    # process config files
    for f in $(find /osixia/service/slapd/assets/config/bootstrap/ldif  -name \*.ldif -type f); do
      echo "Processing file ${f}"
      ldapmodify -Y EXTERNAL -Q -H ldapi:/// -f $f
    done

  fi

  # TLS config
  if [ "${USE_TLS,,}" == "true" ]; then

    echo "Use TLS"

    check_tls_files $SSL_CA_CRT_FILENAME $SSL_CRT_FILENAME $SSL_KEY_FILENAME

    # adapt tls ldif
    sed -i "s,/osixia/service/slapd/assets/ssl/ca.crt,/osixia/service/slapd/assets/ssl/${SSL_CA_CRT_FILENAME},g" /osixia/service/slapd/assets/config/tls/tls-enable.ldif
    sed -i "s,/osixia/service/slapd/assets/ssl/ldap.crt,/osixia/service/slapd/assets/ssl/${SSL_CRT_FILENAME},g" /osixia/service/slapd/assets/config/tls/tls-enable.ldif
    sed -i "s,/osixia/service/slapd/assets/ssl/ldap.key,/osixia/service/slapd/assets/ssl/${SSL_KEY_FILENAME},g" /osixia/service/slapd/assets/config/tls/tls-enable.ldif

    ldapmodify -Y EXTERNAL -Q -H ldapi:/// -f /osixia/service/slapd/assets/config/tls/tls-enable.ldif

    [[ -f "$WAS_STARTED_WITH_TLS" ]] && rm -f "$WAS_STARTED_WITH_TLS"
    touch $WAS_STARTED_WITH_TLS
    echo "export PREVIOUS_SSL_CA_CRT_FILENAME=${SSL_CA_CRT_FILENAME}" >> $WAS_STARTED_WITH_TLS
    echo "export PREVIOUS_SSL_CRT_FILENAME=${SSL_CRT_FILENAME}" >> $WAS_STARTED_WITH_TLS
    echo "export PREVIOUS_SSL_KEY_FILENAME=${SSL_KEY_FILENAME}" >> $WAS_STARTED_WITH_TLS
    chmod +x $WAS_STARTED_WITH_TLS

    # ldap client config
    sed -i "s,TLS_CACERT.*,TLS_CACERT /osixia/service/slapd/assets/ssl/${SSL_CA_CRT_FILENAME},g" /etc/ldap/ldap.conf
    echo "TLS_REQCERT demand" >> /etc/ldap/ldap.conf

    [[ -f "$HOME/.ldaprc" ]] && rm -f $HOME/.ldaprc
    touch $HOME/.ldaprc
    echo "TLS_CERT /osixia/service/slapd/assets/ssl/${SSL_CRT_FILENAME}" >> $HOME/.ldaprc
    echo "TLS_KEY /osixia/service/slapd/assets/ssl/${SSL_KEY_FILENAME}" >> $HOME/.ldaprc

  else

    echo "Don't use TLS"

    [[ -f "$WAS_STARTED_WITH_TLS" ]] && rm -f "$WAS_STARTED_WITH_TLS"
    ldapmodify -c -Y EXTERNAL -Q -H ldapi:/// -f /osixia/service/slapd/assets/config/tls/tls-disable.ldif || true

  fi


  # replication config
  if [ "${USE_REPLICATION,,}" == "true" ]; then

    if [ -e "$WAS_STARTED_WITH_REPLICATION" ]; then
      echo "Replication already set"
    else
      echo "Use replication"

      # copy template file
      cp /osixia/service/slapd/assets/config/replication/replication-enable-template.ldif /osixia/service/slapd/assets/config/replication/replication-enable.ldif

      REPLICATION_HOSTS=($REPLICATION_HOSTS)
      i=1
      for host in "${REPLICATION_HOSTS[@]}"
      do

        #host var contain a variable name, we access to the variable value
        host=${!host}

        sed -i "s|{{ REPLICATION_HOSTS }}|olcServerID: $i ${host}\n{{ REPLICATION_HOSTS }}|g" /osixia/service/slapd/assets/config/replication/replication-enable.ldif
        sed -i "s|{{ REPLICATION_HOSTS_CONFIG_SYNC_REPL }}|olcSyncRepl: rid=00$i provider=${host} ${REPLICATION_CONFIG_SYNCPROV}\n{{ REPLICATION_HOSTS_CONFIG_SYNC_REPL }}|g" /osixia/service/slapd/assets/config/replication/replication-enable.ldif
        sed -i "s|{{ REPLICATION_HOSTS_HDB_SYNC_REPL }}|olcSyncRepl: rid=10$i provider=${host} ${REPLICATION_HDB_SYNCPROV}\n{{ REPLICATION_HOSTS_HDB_SYNC_REPL }}|g" /osixia/service/slapd/assets/config/replication/replication-enable.ldif

        ((i++))
      done

      get_base_dn
      sed -i "s|\$BASE_DN|$BASE_DN|g" /osixia/service/slapd/assets/config/replication/replication-enable.ldif
      sed -i "s|\$LDAP_ADMIN_PASSWORD|$LDAP_ADMIN_PASSWORD|g" /osixia/service/slapd/assets/config/replication/replication-enable.ldif
      sed -i "s|\$LDAP_CONFIG_PASSWORD|$LDAP_CONFIG_PASSWORD|g" /osixia/service/slapd/assets/config/replication/replication-enable.ldif

      sed -i "/{{ REPLICATION_HOSTS }}/d" /osixia/service/slapd/assets/config/replication/replication-enable.ldif
      sed -i "/{{ REPLICATION_HOSTS_CONFIG_SYNC_REPL }}/d" /osixia/service/slapd/assets/config/replication/replication-enable.ldif
      sed -i "/{{ REPLICATION_HOSTS_HDB_SYNC_REPL }}/d" /osixia/service/slapd/assets/config/replication/replication-enable.ldif

      ldapmodify -c -Y EXTERNAL -Q -H ldapi:/// -f /osixia/service/slapd/assets/config/replication/replication-enable.ldif
      touch $WAS_STARTED_WITH_REPLICATION
    fi

  else

    echo "Don't use replication"
    [[ -f "$WAS_STARTED_WITH_REPLICATION" ]] && rm -f "$WAS_STARTED_WITH_REPLICATION"
    ldapmodify -c -Y EXTERNAL -Q -H ldapi:/// -f /osixia/service/slapd/assets/config/replication/replication-disable.ldif || true

    rm -f $WAS_STARTED_WITH_REPLICATION

  fi

  # stop OpenLDAP
  SLAPD_PID=$(cat /run/slapd/slapd.pid)
  echo "Kill slapd, pid: $SLAPD_PID"
  kill -INT $SLAPD_PID
  echo "[ok]"

  sleep 3

  touch $FIRST_START_DONE
fi

exit 0
