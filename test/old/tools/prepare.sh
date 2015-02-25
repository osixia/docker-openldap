#!/bin/sh

mkdir -p $testDir

dir=$(dirname $0)
$dir/delete-container.sh
$dir/delete-image.sh
