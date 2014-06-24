#!/bin/sh

# remove test container
res=$(docker.io ps -a | grep -c "$testContainer")

if [ $res -ne 0 ]; then
  docker.io stop $testContainer
  docker.io rm $testContainer
fi
