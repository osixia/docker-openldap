from	ubuntu:12.04

# Configure apt
run	echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >> /etc/apt/sources.list
run	apt-get -y update

# Don't start slapd on install
run	echo "#!/bin/sh\nexit 101" >/usr/sbin/policy-rc.d
run	chmod +x /usr/sbin/policy-rc.d

# Install slapd
run	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y slapd

# Default configuration: can be overridden at the docker command line
env	LDAP_ROOTPASS toor
env	LDAP_ORGANISATION Acme Widgets Inc.
env	LDAP_DOMAIN example.com

expose 389

add	./slapd-start /usr/bin/slapd-start
cmd	["/usr/bin/slapd-start"]

# To store the data outside the container, mount /var/lib/ldap as a data volume

# vim:ts=8:noet:
