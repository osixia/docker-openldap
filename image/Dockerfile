FROM osixia/baseimage:0.10.3
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add openldap user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r openldap && useradd -r -g openldap openldap

# Install OpenLDAP and ldap-utils (and ssl-kit from baseimage), remove default ldap db
RUN apt-get -y update && /sbin/enable-service ssl-kit \
	&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends slapd ldap-utils \
	&& rm -rf /var/lib/ldap

# Add install script and OpenLDAP assets
ADD service/install.sh /tmp/install.sh
ADD service/slapd/assets /osixia/slapd

# Run install script and clean all
RUN ./tmp/install.sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yml /etc/env.yml

# Add OpenLDAP container start config & daemon
ADD service/slapd/container-start.sh /etc/my_init.d/slapd
ADD service/slapd/daemon.sh /etc/service/slapd/run

# Set OpenLDAP data and config directories in a data volume
VOLUME ["/var/lib/ldap", "/etc/ldap/slapd.d"]

# Expose ldap default port
EXPOSE 389