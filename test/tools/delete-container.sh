#!/bin/sh

. $(dirname $0)/config.prop

# remove openldap test container
res=$(docker.io ps -a | grep -c "$openldapTestContainer")

if [ $res -ne 0 ]; then
  docker.io stop openldap-test-container
  docker.io rm openldap-test-container
fi
