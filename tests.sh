#!/bin/sh

# Test script
out=tests.out

echo_error () {
  echo "$*: $(tput setaf 1)failed$(tput sgr0)"
}

echo_ok () {
  echo "$*: ok"
}

run_test () {
  fction=$1
  ./tests/$1.sh | tee $out
}

run_test build

if [ $(grep -c "Successfully built" ./tests.out) -eq 0 ]; then
  echo_error $fction
else
  echo_ok  $fction
fi

rm $out

run_test run-simple
