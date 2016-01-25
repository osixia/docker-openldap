#!/bin/bash

# print a file encode into base64

FILE=$1

FILE_ENCODED=$(cat $FILE | base64)
FILE_ENCODED=`echo ${FILE_ENCODED} | tr -d '\n'`
FILE_ENCODED=`echo ${FILE_ENCODED} | tr -d ' '`
echo  $FILE_ENCODED
