#!/bin/sh

sudo docker.io run --dns=127.0.0.1 -v ./ssl:/etc/ldap/ssl -p 389:389 -d openldap
