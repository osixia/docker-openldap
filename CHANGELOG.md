# Changelog

## 1.1.7
Update to light-baseimage:0.2.6

## 1.1.6
Fix :
  - Upgrade to 1.1.5 startup issues with cfssl-helper #73

Update to light-baseimage:0.2.5

## 1.1.5
Fix :
  - Restarting container with new environment #44
  - Cannot rerun with customized certificate at 1.1.1 #36

## 1.1.4
Fix :
  - Remove environment variable LDAP_TLS_PROTOCOL_MIN as it takes no effect, see #69
  - Adjust default GnuTLS cipher string according to Red Hat's TLS hardening guide.
    This by default also restricts the TLS protocol version to 1.2. For reference,
    see #69
  - Fix Error in Adding "Billy" #71
  - Add docker-compose.yml example and update kubernetes examples #52

Merge pull request :
  - Update LDAP_TLS_CIPHER_SUITE, remove LDAP_TLS_PROTOCOL_MIN #70
  - fixed LDAP_BACKEND for readonly user #62

## 1.1.3
Merge pull request :
  - Use mdb over hdb #50
  - Ignore lost+found directories #53
  - Remove Volume command from Dockerfile #56

Update to light-baseimage:0.2.4

Release Note:
  In this version the new environment variable LDAP_BACKEND let you set the the backend used by your ldap database.
  By default it's hdb. In comming versions 1.2.x the default will be changed to mdb.

  Environment variable LDAP_REPLICATION_HDB_SYNCPROV changed to LDAP_REPLICATION_DB_SYNCPROV

## 1.1.2
Merge pull request :
  - Honor LDAP_LOG_LEVEL on startup #39

Fix :
  - slapd tcp bind is network not interface, and so does not respond on overlay networks #35
  - specify base_dn without domain #37

## 1.1.1
Update to light-baseimage:0.2.2

## 1.1.0
Update to light-baseimage:0.2.1 :
  - Use \*.startup.yaml environment files to keep configuration secrets
  - Use cfssl tool to generate tls certs
  - Use log-helper to write leveled log messages
  - Allow copy of /container/service and mounted files to /container/run/service dir usefull for write only filesystems and avoid file permissions problems

New feature :
  - Add enforcing TLS options (#26)

Fix :
  - Should SSL certs be copied on load? (#25)

## 1.0.9
Update to light-baseimage:0.2.0

Makefile with build no cache

## 1.0.8
Fix an other startup bug ! whuhu

## 1.0.7
Fix startup bug

## 1.0.6
Use light-baseimage:0.1.5

## 1.0.5
Use light-baseimage:0.1.4

Fix replication bug when the hostname was changed

## 1.0.4
Use light-baseimage:0.1.3

## 1.0.3
Use light-baseimage:0.1.2

Fix :
  - Re-running container with volumes won't start #19

## 1.0.2

Add TLS environment variable :
  - LDAP_TLS_CIPHER_SUITE
  - LDAP_TLS_PROTOCOL_MIN
  - LDAP_TLS_VERIFY_CLIENT

## 1.0.1

Upgrade baseimage: light-baseimage:0.1.1

Rename environment variables

Fix :
  - OpenLdap container won't start when dhparam.pem is missing in bound volume #13

## 1.0.0

Use light-baseimage

Improve documentation

## 0.10.2

New features :
  - Bootstrap config, only on non existing slapd config
  - Limit max open file descriptors to fix slapd memory usage (#9)
  - Don't disable network access from outside (#8)
  - Make log level configurable via environment variable (#7)
  - Support for ldaps (#10)


Fix :
  - Unable to start container with the following invocation. (#6)

## 0.10.1

New features :
  - Add ldapi
  - Add custom ldap schema
  - Auto convert .schema to .ldif


Fix :
  - Docker VOLUME is not needed to be able to stop a container without losing data (#2)
  - starting from old data (#3)

## 0.10.0
New version initial release
