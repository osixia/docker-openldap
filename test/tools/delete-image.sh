#!/bin/sh

# remove openldap test image
docker.io images > testimage.out

if [ "$(grep -c "openldap-test" ./testimage.out)" -ne 0 ]; then
  docker.io rmi openldap-test
fi

rm testimage.out
