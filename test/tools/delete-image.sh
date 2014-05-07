#!/bin/sh

. $(dirname $0)/config.prop

# remove openldap test image
res=$(docker.io images | grep -c "$openldapTestImage")

if [ $res -ne 0 ]; then
  docker.io rmi $openldapTestImage
fi
