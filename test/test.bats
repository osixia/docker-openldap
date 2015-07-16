#!/usr/bin/env bats
load test_helper

@test "image build" {

  run build_image
  [ "$status" -eq 0 ]

}

@test "ldapsearch new database" {
skip
  run_image -h ldap.example.org -e USE_TLS=false
  wait_service slapd
  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.example.org -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
  clear_container

  [ "$status" -eq 0 ]

}

@test "ldapsearch new database with strict TLS" {
skip
  run_image -h ldap.example.org
  wait_service slapd
  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.example.org -b dc=example,dc=org -ZZ -D "cn=admin,dc=example,dc=org" -w admin
  clear_container

  [ "$status" -eq 0 ]

}

@test "ldapsearch new database with strict TLS and custom ca/crt" {
skip
  run_image -h ldap.osixia.net -v $BATS_TEST_DIRNAME/ssl:/osixia/service/slapd/assets/ssl -e SSL_CRT_FILENAME=ldap-test.crt -e SSL_KEY_FILENAME=ldap-test.key -e SSL_CA_CRT_FILENAME=ca-test.crt
  wait_service slapd
  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.osixia.net -b dc=example,dc=org -ZZ -D "cn=admin,dc=example,dc=org" -w admin
  clear_container

  chown -R $UNAME:$UNAME $BATS_TEST_DIRNAME || true

  [ "$status" -eq 0 ]

}

@test "ldapsearch existing database and config" {
skip
  run_image -h ldap.example.org -e USE_TLS=false -v $BATS_TEST_DIRNAME/database:/var/lib/ldap -v $BATS_TEST_DIRNAME/config:/etc/ldap/slapd.d
  wait_service slapd
  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.example.org -b dc=osixia,dc=net -D "cn=admin,dc=osixia,dc=net" -w admin
  clear_container

  chown -R $UNAME:$UNAME $BATS_TEST_DIRNAME || true

  [ "$status" -eq 0 ]

}


@test "replication with new databases and strict TLS" {

  tmp_file="$BATS_TMPDIR/docker-test"

  # replication ldap server
  LDAP_REPL_CID=$(docker run -h ldap2.example.org -e USE_REPLICATION=true -e IS_REPLICATION_TEST=true -d $NAME:$VERSION)
  LDAP_REPL_IP=$(get_container_ip_by_cid $LDAP_REPL_CID)

  # ldap server
  run_image -h ldap.example.org -e USE_REPLICATION=true -e IS_REPLICATION_TEST=true

  # add route to hosts
  docker exec $LDAP_REPL_CID /osixia/service/slapd/assets/test/add-host.sh $CONTAINER_IP ldap.example.org
  docker exec $CONTAINER_ID /osixia/service/slapd/assets/test/add-host.sh $LDAP_REPL_IP ldap2.example.org

  # wait services on both servers
  wait_service slapd
  wait_service_by_cid $LDAP_REPL_CID slapd

  # add user on ldap2.example.org
  docker exec $LDAP_REPL_CID ldapadd -x -D "cn=admin,dc=example,dc=org" -w admin -f /osixia/service/slapd/assets/test/new-user.ldif -h ldap2.example.org -ZZ

  sleep 5

  # search user on ldap.example.org
  docker exec $CONTAINER_ID ldapsearch -x -h ldap.example.org -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin -ZZ >> $tmp_file
  run grep -c "billy" $tmp_file

  rm $tmp_file
  clear_container

  clear_containers_by_cid $LDAP_REPL_CID

  [ "$status" -eq 0 ]
  [ "$output" = "6" ]

}
