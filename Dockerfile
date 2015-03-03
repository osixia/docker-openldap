FROM osixia/baseimage:0.6.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.fr>

# From Nick Stenning's work
# https://github.com/nickstenning/docker-slapd

# Default configuration: can be overridden at the docker command line
ENV LDAP_ADMIN_PWD toor
ENV LDAP_ORGANISATION Example Inc.
ENV LDAP_DOMAIN example.com

# /!\ To store the data outside the container, 
# mount /var/lib/ldap and /etc/ldap/slapd.d as a data volume add
# -v /some/host/directory:/var/lib/ldap and -v /some/other/host/directory:/etc/ldap/slapd.d
# to the run command

# Disable SSH
# RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Enable dnsmasq
RUN /sbin/enable-service dnsmasq

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Resynchronize the package index files from their sources
RUN apt-get -y update

# Install openldap (slapd) and ldap-utils
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends slapd ldap-utils openssl

# Expose ldap default port
EXPOSE 389

# Create TLS certificats directory
RUN mkdir /etc/ldap/ssl

# Add config directory 
RUN mkdir /etc/ldap/config
ADD service/slapd/config /etc/ldap/config

# Add slapd deamon
RUN mkdir /etc/service/slapd
ADD service/slapd/slapd.sh /etc/service/slapd/run

# Clear out the local repository of retrieved package files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
