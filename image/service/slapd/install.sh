#!/bin/bash -e

# Add openldap user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r openldap && useradd -r -g openldap openldap

# Install OpenLDAP, ldap-utils
LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
slapd ldap-utils

# Remove default ldap db
rm -rf /var/lib/ldap /etc/ldap/slapd.d
