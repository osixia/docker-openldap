#!/bin/sh

dir=$(dirname $0)
$dir/delete-container.sh
$dir/delete-image.sh
