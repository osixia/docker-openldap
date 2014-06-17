#!/bin/sh

# Usage
# sudo ./test.sh 
# add -v for verbose mode (or type whatever you like !) :p

. test/tools/run.sh

run_test tools/build-container "Successfully built"
run_test simple "dn: dc=example,dc=com"
run_test tls "dn: dc=example,dc=com"
run_test db "dn: dc=otherdomain,dc=com"

. test/tools/end.sh

