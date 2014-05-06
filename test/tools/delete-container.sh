#!/bin/sh

# remove openldap test container
sudo docker.io ps -a > testcontainer.out

if [ "$(grep -c "openldap-test-container" ./testcontainer.out)" -ne 0 ]; then
  sudo docker.io stop openldap-test-container
  sudo docker.io rm openldap-test-container
fi

rm testcontainer.out
