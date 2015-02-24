FROM osixia/baseimage:0.10.2
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add openldap user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r openldap && useradd -r -g openldap openldap

# Install OpenLDAP and ldap-utils (with ssl-kit from baseimage), remove default db
RUN apt-get -y update && /sbin/enable-service ssl-kit
	&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends slapd ldap-utils
	&& rm -rf /var/lib/ldap

# Add install script and OpenLDAP assets
ADD service/install.sh /tmp/install.sh
ADD service/slapd/assets /osixia/slapd

# Run install script and clean all
RUN ./tmp/install.sh && rm /tmp/install.sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yml /etc/env.yml

# Add OpenLDAP container start config & daemon
ADD service/slapd/container-start.sh /etc/my_init.d/1-slapd
ADD service/slapd/daemon.sh /etc/service/slapd/run

# Set OpenLDAP data and config directories in a data volume
VOLUME ["/var/lib/ldap", "/etc/ldap/slapd.d"]

# Expose ldap default port
EXPOSE 389

# Disable SSH
# RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Enable dnsmasq
RUN /sbin/enable-service dnsmasq ca-authority

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add Mandriva MDS repository
RUN echo "deb http://mds.mandriva.org/pub/mds/debian wheezy main" >> /etc/apt/sources.list

# Resynchronize the package index files from their sources
RUN apt-get -y update

# Install openldap (slapd) and ldap-utils
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends slapd ldap-utils  mmc-agent python-mmc-mail

# Expose ldap and mmc-agent default ports
EXPOSE 389 7080

# Create TLS certificats directory
RUN mkdir /etc/ldap/ssl

# Add config directory 
ADD service/slapd/assets/config /etc/ldap/config
ADD service/mmc-agent/assets /etc/mmc/agent/assets

# Add slapd deamon
ADD service/slapd/slapd.sh /etc/service/slapd/run

# Add mmc-agent deamon
ADD service/mmc-agent/mmc-agent.sh /etc/service/mmc-agent/run

# Clear out the local repository of retrieved package files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
