#!/bin/sh

# remove openldap test containers
sudo docker.io ps -a > testcontainers.out

if [ "$(grep -c "openldap-test-container" ./testcontainers.out)" -ne 0 ]; then
  sudo docker.io stop openldap-test-container
  sudo docker.io rm openldap-test-container
fi

rm testcontainers.out
