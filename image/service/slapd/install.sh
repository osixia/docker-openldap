#!/bin/bash -e
# this script is run during the image build

# remove default ldap db
rm -rf /var/lib/ldap /etc/ldap/slapd.d
