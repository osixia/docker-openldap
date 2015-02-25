#!/usr/bin/env bats
load test_helper

@test "image build" {

  run build_image
  [ "$status" -eq 0 ]

}

@test "ldapsearch new database" {

  run_image -e USE_TLS=false
  wait_service slapd
  run docker exec $CONTAINER_ID ldapsearch -x -h 127.0.0.1 -b dc=example,dc=org
  clear_container

  [ "$status" -eq 0 ]

}

@test "ldapsearch new database with strict TLS" {

  run_image
  wait_service slapd
  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.example.org -b dc=example,dc=org -ZZ
  clear_container

  [ "$status" -eq 0 ]

}

@test "ldapsearch new database with strict TLS and custom ca/crt" {

  run_image -v $BATS_TEST_DIRNAME/ssl:/osixia/slapd/ssl -e SSL_CRT_FILENAME=test-ldap.crt -e SSL_KEY_FILENAME=test-ldap.key -e SSL_CA_CRT_FILENAME=test-ca.crt
  wait_service slapd
  run docker exec $CONTAINER_ID ldapsearch -x -h ldap-test.example.com -b dc=example,dc=org -ZZ
  clear_container

  chown -R $UNAME:$UNAME $BATS_TEST_DIRNAME/ssl || true

  [ "$status" -eq 0 ]

}

@test "ldapsearch existing database and config" {
  skip
  run_image -e USE_TLS=false -v $BATS_TEST_DIRNAME/database:/var/lib/ldap 
  wait_service slapd
  sleep 60
  run docker exec $CONTAINER_ID ldapsearch -x -h 127.0.0.1 -b dc=test-ldap,dc=osixia,dc=net
  clear_container

  chown -R $UNAME:$UNAME $BATS_TEST_DIRNAME/database || true

  [ "$status" -eq 0 ]

}