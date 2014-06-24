#!/bin/sh

./test/tools/delete-container.sh 
./test/tools/delete-image.sh > /dev/null 2>&1

echo "------- End -------"
echo $error " failed " $ok " succeeded"
