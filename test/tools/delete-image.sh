#!/bin/sh

# remove test image
res=$(docker images | grep -c "$testImage")

if [ $res -ne 0 ]; then
  docker rmi $testImage
fi
