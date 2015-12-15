FROM osixia/light-baseimage:0.2.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Use baseimage's init system.
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/run
CMD ["/container/tool/run"]

# Add openldap user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r openldap && useradd -r -g openldap openldap

# Install OpenLDAP, ldap-utils and ssl-helper from baseimage and remove default ldap db
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service-available
RUN apt-get -y update \
    && /container/tool/install-service-available ssl-helper-gnutls \
	  && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
	     slapd ldap-utils \
	  && rm -rf /var/lib/ldap /etc/ldap/slapd.d

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script and clean all
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yaml /container/environment/env.yaml

# Set OpenLDAP data and config directories in a data volume
VOLUME ["/var/lib/ldap", "/etc/ldap/slapd.d"]

# Expose default ports for ldap and ldaps
EXPOSE 389 636
