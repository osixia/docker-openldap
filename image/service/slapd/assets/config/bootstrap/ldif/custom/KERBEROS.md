This directory contains two files that implement a sane default
KDC configuration. Since 02-kdc-security modifies the LDAP_BACKEND
it must be run while the LDAP server is down.

The organizationalUnits created, users and services, can be easily
changed by mounting a docker volume over this directory. Important:
if you do this you MUST update the script that creates the KDC
entries as well!
