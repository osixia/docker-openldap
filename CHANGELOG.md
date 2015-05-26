## 0.10.2 (release date: 2015-05-25)
  - Bootstrap config, only non existing slapd config

  Fixes:
  - Unable to start container with the following invocation. #6

  Thanks to **cknitt** :
  - Limit max open file descriptors to fix slapd memory usage #9
  - Don't disable network access from outside #8
  - Make log level configurable via environment variable #7
  - Support for ldaps #10

## 0.10.1 (release date: 2015-05-17)
  - Add ldapi
  - Add custom ldap schema
  - Auto convert .schema to .ldif

  Fixes :
  - Docker VOLUME is not needed to be able to stop a container without losing data #2
  - starting from old data #3

## 0.10.0 (release date: 2015-03-03)
  - New version initial release
