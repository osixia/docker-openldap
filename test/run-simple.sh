#!/bin/sh

docker.io run --name openldap-test-container -p 65389:389 -d openldap-test
sleep 5
ldapsearch -x -h localhost -p 65389 -b dc=example,dc=com

$(pwd)/test/tools/delete-container.sh
