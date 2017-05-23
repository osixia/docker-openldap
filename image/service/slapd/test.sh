#!/bin/bash -e

# Copy testing data to their respective directories on an as-needed basis
mkdir -p /var/lib/ldap
mkdir -p /etc/ldap/slapd.d
cp -rf /container/test/database/* /var/lib/ldap/ || true
cp -rf /container/test/config/* /etc/ldap/slapd.d/ || true
