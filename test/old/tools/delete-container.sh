#!/bin/sh

# remove test container
res=$(docker ps -a | grep -c "$testContainer")

if [ $res -ne 0 ]; then
  docker stop $testContainer
  docker rm $testContainer
fi
