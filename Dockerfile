FROM osixia/baseimage:0.10.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# From Nick Stenning's work
# https://github.com/nickstenning/docker-slapd

# Default configuration: can be overridden at the docker command line
ENV DOMAIN_NAME ldap.example.com
ENV LDAP_DOMAIN example.com
ENV LDAP_ADMIN_PWD toor
ENV LDAP_ORGANISATION Example Inc.

ENV WITH_MMC_AGENT false
ENV MMC_AGENT_LOGIN mmc-docker
ENV MMC_AGENT_PASSWORD passw0rd

# /!\ To store the data outside the container, 
# mount /var/lib/ldap and /etc/ldap/slapd.d as a data volume add
# -v /some/host/directory:/var/lib/ldap and -v /some/other/host/directory:/etc/ldap/slapd.d
# to the run command

VOLUME ["/var/lib/ldap", "/etc/ldap/slapd.d"]

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
