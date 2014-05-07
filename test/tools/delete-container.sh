#!/bin/sh

# remove openldap test container
docker.io ps -a > testcontainer.out

if [ "$(grep -c "openldap-test-container" ./testcontainer.out)" -ne 0 ]; then
  docker.io stop openldap-test-container
  docker.io rm openldap-test-container
fi

rm testcontainer.out
