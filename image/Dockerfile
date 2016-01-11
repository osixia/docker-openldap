FROM osixia/light-baseimage:0.2.1-dev
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Use baseimage's init system.
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/run
# ENTRYPOINT ["/container/tool/run"]

# Add openldap user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r openldap && useradd -r -g openldap openldap

# Install OpenLDAP, ldap-utils and cfssl from baseimage and remove default ldap db
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service-available
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/.cfssl
RUN apt-get -y update \
    && /container/tool/install-service-available cfssl \
	  && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
       slapd ldap-utils openssl \
	  && rm -rf /var/lib/ldap /etc/ldap/slapd.d

# Add service directory to /container/service
ADD service /container/service

# Clean tmp and apt-get files
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD environment /container/environment/99-default

# Set OpenLDAP data and config directories in a data volume
VOLUME ["/var/lib/ldap", "/etc/ldap/slapd.d"]

# Expose default ports for ldap and ldaps
EXPOSE 389 636
