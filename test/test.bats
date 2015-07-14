#!/usr/bin/env bats
load test_helper

@test "image build" {

  run build_image
  [ "$status" -eq 0 ]

}

@test "ldapsearch new database" {

  run_image -e USE_TLS=false
  wait_service slapd
  run docker exec $CONTAINER_ID ldapsearch -x -h 127.0.0.1 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
  clear_container

  [ "$status" -eq 0 ]

}

@test "ldapsearch new database with strict TLS" {

  run_image
  wait_service slapd
  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.example.org -b dc=example,dc=org -ZZ -D "cn=admin,dc=example,dc=org" -w admin
  clear_container

  [ "$status" -eq 0 ]

}

@test "ldapsearch new database with strict TLS and custom ca/crt" {

  run_image -v $BATS_TEST_DIRNAME/ssl:/osixia/slapd/assets/ssl -e SSL_CRT_FILENAME=ldap-test.crt -e SSL_KEY_FILENAME=ldap-test.key -e SSL_CA_CRT_FILENAME=ca-test.crt
  wait_service slapd
  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.osixia.net -b dc=example,dc=org -ZZ -D "cn=admin,dc=example,dc=org" -w admin
  clear_container

  chown -R $UNAME:$UNAME $BATS_TEST_DIRNAME || true

  [ "$status" -eq 0 ]

}

@test "ldapsearch existing database and config" {

  run_image -e USE_TLS=false -v $BATS_TEST_DIRNAME/database:/var/lib/ldap -v $BATS_TEST_DIRNAME/config:/etc/ldap/slapd.d
  wait_service slapd
  run docker exec $CONTAINER_ID ldapsearch -x -h 127.0.0.1 -b dc=osixia,dc=net -D "cn=admin,dc=osixia,dc=net" -w admin
  clear_container

  chown -R $UNAME:$UNAME $BATS_TEST_DIRNAME || true

  [ "$status" -eq 0 ]

}
