#!/bin/sh


rm -rf $testDir
./test/tools/delete-container.sh 
./test/tools/delete-image.sh > /dev/null 2>&1

echo "------- End -------"
echo $error " failed " $ok " succeeded"

if [ "$error" -eq 0 ]; then
  exit 0
else
  exit 1
fi
