#!/bin/sh

# Usage
# sudo ./test.sh 
# add -v for verbose mode (or type whatever you like !) :p

. test/config
. test/tools/run.sh

run_test tools/build-container.sh "Successfully built"
run_test simple.sh "dn: dc=example,dc=com"
run_test tls.sh "dn: dc=example,dc=com"
run_test db.sh "dn: dc=otherdomain,dc=com"

. test/tools/end.sh

