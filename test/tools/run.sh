#!/bin/sh

# Usage
# sudo ./test.sh 
# add -v for verbose mode (or type whatever you like !) :p

verbose=$1
error=0
ok=0

echo_start () {
  echo "------- Test: $* -------"
}

echo_error () {
  echo "\n$(tput setaf 1)/!\ $* failed$(tput sgr0)\n"
  error=`expr $error + 1`
}

echo_ok () {
  echo "\n--> $* ok\n"
  ok=`expr $ok + 1`
}

run_test () {
  fction=$1
  out=test/test.out

  echo_start $fction

  if [ -z ${verbose} ]; then
    ./test/$1.sh > $out 2>&1
  else
    ./test/$1.sh | tee $out 2>&1
  fi
  
  if [ "$(grep -c "$2" $out)" -eq 0 ]; then
    echo_error $fction
  else
    echo_ok  $fction
  fi

  rm $out
}

./test/tools/prepare.sh > /dev/null 2>&1
