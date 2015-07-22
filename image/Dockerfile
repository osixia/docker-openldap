FROM osixia/light-baseimage:0.1.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Use osixia/light-baseimage's init system.
CMD ["/osixia/tool/run"]

# Add service directory to /osixia/service
ADD service /osixia/service

# Scripts /sbin/add-service-available
# /sbin/install-service and /sbin/clean-container
# are tools from osixia/light-baseimage
RUN /sbin/add-service-available ssl-helper-gnutls \
 && /sbin/install-service \
 && /sbin/clean-container

# /sbin/add-service-available ssl-helper-gnutls
# Add ssl-helper-gnutls, used to generate TLS default certificates

# /sbin/install-service
# make an apt-get update
# run /osixia/service/*/install.sh
# link /osixia/service/*/container-start.sh to /etc/my_init.d/*
# link /osixia/service/*/daemon.sh to /etc/service/*/run

# Files in /etc/my_init.d will be run during container start,
# Files in /etc/service/*/run are the process run by the docker image

# /sbin/clean-container remove unnecessary files

# More information :
# https://github.com/osixia/docker-light-baseimage


# Add default env variables
ADD env.yaml /etc/env.yaml

# Set OpenLDAP data and config directories in a data volume
VOLUME ["/var/lib/ldap", "/etc/ldap/slapd.d"]

# Expose default ports for ldap and ldaps
EXPOSE 389 636
