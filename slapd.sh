#!/bin/sh

set -eu

status () {
  echo "---> ${@}" >&2
}

set -x
: LDAP_ADMIN_PWD=${LDAP_ADMIN_PWD}
: LDAP_DOMAIN=${LDAP_DOMAIN}
: LDAP_ORGANISATION=${LDAP_ORGANISATION}

if [ ! -e /var/lib/ldap/docker_bootstrapped ]; then
  status "configuring slapd for first run"

  cat <<EOF | debconf-set-selections
slapd slapd/internal/generated_adminpw password ${LDAP_ADMIN_PWD}
slapd slapd/internal/adminpw password ${LDAP_ADMIN_PWD}
slapd slapd/password2 password ${LDAP_ADMIN_PWD}
slapd slapd/password1 password ${LDAP_ADMIN_PWD}
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

  if [ -e /etc/ldap/ssl/ldap.crt ] && [ -e /etc/ldap/ssl/ldap.key ] && [ -e /etc/ldap/ssl/ca.crt ]; then
    status "certificates found"
  
    chown openldap /etc/ldap/ssl/ldap.key
    chmod 400 /etc/ldap/ssl/ldap.key

    echo 'TLSCipherSuite   HIGH:MEDIUM:+SSLv3' >> /usr/share/slapd/slapd.conf
    echo 'TLSCACertificateFile /etc/ldap/ssl/ca.crt' >> /usr/share/slapd/slapd.conf
    echo 'TLSCertificateFile /etc/ldap/ssl/ldap.crt' >> /usr/share/slapd/slapd.conf
    echo 'TLSCertificateKeyFile /etc/ldap/ssl/ldap.key' >> /usr/share/slapd/slapd.conf
    echo 'TLSVerifyClient never' >> /usr/share/slapd/slapd.conf

    sed -i "s/TLS_CACERT.*/TLS_CACERT       \/etc\/ldap\/ssl\/ca.crt/g" /etc/ldap/ldap.conf
    sed -i '/TLS_CACERT/a\TLS_CIPHER_SUITE        HIGH:MEDIUM:+SSLv3' /etc/ldap/ldap.conf

  fi

  touch /var/lib/ldap/docker_bootstrapped

else
  status "found already-configured slapd"
fi

status "starting slapd on default port 389"
set -x
exec /usr/sbin/slapd -h "ldap:///" -u openldap -g openldap -d 0
