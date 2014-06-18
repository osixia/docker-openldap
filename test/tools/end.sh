#!/bin/sh

dir=$(dirname $0)
$dir/delete-container.sh > /dev/null 2>&1
$dir/delete-image.sh > /dev/null 2>&1

echo "------- End -------"
echo $error " failed " $ok " succeeded"
