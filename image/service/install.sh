#!/bin/bash -e
# this script is run during the image build

# Enable access only from docker default network and localhost
echo "slapd: 172.17.0.0/255.255.0.0 127.0.0.1 : ALLOW" >> /etc/hosts.allow
echo "slapd: ALL : DENY" >> /etc/hosts.allow