# Use osixia/light-baseimage
# sources: https://github.com/osixia/docker-light-baseimage
FROM osixia/light-baseimage:1.1.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Add openldap user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r openldap && useradd -r -g openldap openldap

# Install OpenLDAP, ldap-utils and ssl-tools from baseimage and clean apt-get files
# sources: https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/add-service-available
#          https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/download.sh
RUN apt-get -y update \
    && /container/tool/add-service-available :ssl-tools \
	  && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       ldap-utils \
       libsasl2-modules \
       libsasl2-modules-db \
       libsasl2-modules-gssapi-mit \
       libsasl2-modules-ldap \
       libsasl2-modules-otp \
       libsasl2-modules-sql \
       openssl \
       slapd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service

# Add default env variables
ADD environment /container/environment/99-default

# Expose default ldap and ldaps ports
EXPOSE 389 636
