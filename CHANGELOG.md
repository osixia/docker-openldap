# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.2.0] - Unreleased
### Changed
  - Use mdb as default backend

### Fixed
  - startup.sh: Ensure SCHEMAS is sorted #193
  - LDAP_ADMIN_PASSWORD with space breaks container setup #167

## [1.1.11] - 2017-12-19
### Added
  - Add krb5-kdc-ldap with doc examples #171
  - Add support of readonly user in custom bootstrap ldif #162

### Fixed
  - Fix NFS issue #169
  - Create schemas in a consistent order. #174

## [1.1.10] - 2017-11-09
### Changed
  - Upgrade baseimage to light-baseimage:1.1.1

### Fixed
  - Readme #145 #148
  - Let ldapmodify and ldapadd use the same auth #146
  - Enable matching uid's and gid's in the host and container. #156

## [1.1.9] - 2017-07-19
### Added
  - LDAP_RFC2307BIS_SCHEMA option to use rfc2307bis schema instead of nis default schema
  - KEEP_EXISTING_CONFIG option to not change the ldap config

### Changed
  - Upgrade baseimage to light-baseimage:1.1.0 (debian stretch)

## [1.1.8] - 2017-02-16
### Fixed
  - LDAP_ENFORCE_TLS is not working correctly #107
  - Unable to reuse volumes after LDAP_TLS_ENFORCE is true #92

## [1.1.7] - 2016-11-09
### Changed
  - Upgrade baseimage to light-baseimage:0.2.6

## [1.1.6] - 2016-09-02
### Changed
  - Upgrade baseimage to light-baseimage:0.2.5

### Fixed
  - Upgrade to 1.1.5 startup issues with cfssl-helper #73

## [1.1.5] - 2016-08-02
### Fixed
  - Restarting container with new environment #44
  - Cannot rerun with customized certificate at 1.1.1 #36

## [1.1.4] - 2016-07-26
### Fixed
  - Remove environment variable LDAP_TLS_PROTOCOL_MIN as it takes no effect, see #69
  - Adjust default GnuTLS cipher string according to Red Hat's TLS hardening guide.
    This by default also restricts the TLS protocol version to 1.2. For reference,
    see #69
  - Fix Error in Adding "Billy" #71
  - Add docker-compose.yml example and update kubernetes examples #52
  - Update LDAP_TLS_CIPHER_SUITE, remove LDAP_TLS_PROTOCOL_MIN #70
  - fixed LDAP_BACKEND for readonly user #62

## [1.1.3] - 2016-06-09
In this version the new environment variable LDAP_BACKEND let you set the the backend used by your ldap database.
By default it's hdb. In comming versions 1.2.x the default will be changed to mdb.

Environment variable LDAP_REPLICATION_HDB_SYNCPROV changed to LDAP_REPLICATION_DB_SYNCPROV

### Added
  - Use mdb over hdb #50

### Changed
  - Ignore lost+found directories #53
  - LDAP_REPLICATION_HDB_SYNCPROV changed to LDAP_REPLICATION_DB_SYNCPROV
  - Upgrade baseimage to light-baseimage:0.2.4

### Removed
  - Volume command from Dockerfile #56

## [1.1.2] - 2016-03-18
### Fixed
  - Honor LDAP_LOG_LEVEL on startup #39
  - slapd tcp bind is network not interface, and so does not respond on overlay networks #35
  - specify base_dn without domain #37

## [1.1.1] - 2016-02-20
### Changed
  - Upgrade baseimage to light-baseimage:0.2.2

## [1.1.0] - 2016-01-25
### Added
  - Use \*.startup.yaml environment files to keep configuration secrets
  - Use cfssl tool to generate tls certs
  - Use log-helper to write leveled log messages
  - Allow copy of /container/service and mounted files to /container/run/service dir usefull for write only filesystems and avoid file permissions problems
  - Add enforcing TLS options (#26)

### Changed
  - Upgrade baseimage to light-baseimage:0.2.1

### Fixed
  - Should SSL certs be copied on load? (#25)

## [1.0.9] - 2015-12-16
### Added
  - Makefile with build no cache

### Changed
  - Upgrade baseimage to light-baseimage:0.2.0

## [1.0.8] - 2015-11-23
### Fixed
  - An other startup bug ! whuhu

## [1.0.7] - 2015-11-20
### Fixed
  - Startup bug

## [1.0.6] - 2015-11-20
### Changed
  - Upgrade baseimage to light-baseimage:0.1.5

## [1.0.5] - 2015-11-19
### Changed
  - Upgrade baseimage to light-baseimage:0.1.4

### Fixed
  - Replication bug when the hostname was changed

## [1.0.4] - 2015-11-06
### Changed
  - Upgrade baseimage to light-baseimage:0.1.3

## [1.0.3] - 2015-10-26
### Changed
  - Upgrade baseimage to light-baseimage:0.1.2

### Fixed
  - Re-running container with volumes won't start #19

## [1.0.2] - 2015-08-27
### Added
  - LDAP_TLS_CIPHER_SUITE
  - LDAP_TLS_PROTOCOL_MIN
  - LDAP_TLS_VERIFY_CLIENT

## [1.0.1] - 2015-08-18
### Changed
  - Upgrade baseimage to light-baseimage:0.1.1

### Fixed
  - OpenLdap container won't start when dhparam.pem is missing in bound volume #13

## [1.0.0] - 2015-07-24
### Added
  - Improve documentation

### Changed
  - Upgrade baseimage to light-baseimage

## [0.10.2] - 2015-07-14
### Added
  - Bootstrap config, only on non existing slapd config
  - Limit max open file descriptors to fix slapd memory usage (#9)
  - Don't disable network access from outside (#8)
  - Make log level configurable via environment variable (#7)
  - Support for ldaps (#10)

### Fixed
  - Unable to start container with the following invocation. (#6)

## [0.10.1] - 2015-05-17
### Added
  - LDAPI
  - Custom ldap schema
  - Auto convert .schema to .ldif

### Fixed
  - Docker VOLUME is not needed to be able to stop a container without losing data (#2)
  - starting from old data (#3)

## [0.10.0] - 2015-03-03
New version initial release, no changelog before this sorry.
