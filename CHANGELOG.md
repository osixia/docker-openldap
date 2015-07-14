# Changelog

## 0.10.2

  - New features:
    - Bootstrap config, only on non existing slapd config
    - Limit max open file descriptors to fix slapd memory usage (#9)
    - Don't disable network access from outside (#8)
    - Make log level configurable via environment variable (#7)
    - Support for ldaps (#10)


  - Fixes:
    - Unable to start container with the following invocation. (#6)

## 0.10.1

  - New features:
    - Add ldapi
    - Add ldapi
    - Add custom ldap schema
    - Auto convert .schema to .ldif


  - Fixes :
    - Docker VOLUME is not needed to be able to stop a container without losing data (#2)
    - starting from old data (#3)

## 0.10.0
  - New version initial release
