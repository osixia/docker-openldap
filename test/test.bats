#!/usr/bin/env bats
load test_helper

@test "image build" {

  run build_image
  [ "$status" -eq 0 ]

}

@test "ldapsearch new database" {

  run_image -h ldap.example.org -e LDAP_TLS=false
  wait_process slapd

  sleep 5

  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.example.org -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
  clear_container

  [ "$status" -eq 0 ]

}

@test "ldap domain with non-matching ldap base dn" {

  run_image -h ldap.example.org -e LDAP_TLS=false -e LDAP_DOMAIN=example.com -e LDAP_BASE_DN="dc=example,dc=org"

  sleep 5

  CSTATUS=$(check_container)
  clear_container

  [ "$CSTATUS" != "running 0" ]

}

@test "ldap domain with matching ldap base dn subdomain" {

  run_image -h ldap.example.fr -e LDAP_TLS=false -e LDAP_DOMAIN=example.fr -e LDAP_BASE_DN="ou=myou,o=example,c=fr"

  sleep 5

  CSTATUS=$(check_container)
  clear_container

  [ "$CSTATUS" == "running 0" ]

}

@test "ldap base dn domain with matching ldap subdomain" {

  run_image -h ldap.example.fr -e LDAP_TLS=false -e LDAP_DOMAIN=mysub.example.fr -e LDAP_BASE_DN="o=example,c=fr"

  sleep 5

  CSTATUS=$(check_container)
  clear_container

  [ "$CSTATUS" == "running 0" ]

}

@test "ldap domain with ldap base dn subdomain included" {

  run_image -h ldap.example.com -e LDAP_TLS=false -e LDAP_DOMAIN=example.com -e LDAP_BASE_DN="ou=myou,o=example,dc=com,c=fr"

  sleep 5

  CSTATUS=$(check_container)
  clear_container

  [ "$CSTATUS" != "running 0" ]

}

@test "ldapsearch database from created volumes" {

  rm -rf VOLUMES && mkdir -p VOLUMES/config VOLUMES/database
  LDAP_CID=$(docker run -h ldap.example.org -e LDAP_TLS=false --volume $PWD/VOLUMES/database:/var/lib/ldap --volume $PWD/VOLUMES/config:/etc/ldap/slapd.d -d $NAME:$VERSION)
  wait_process_by_cid $LDAP_CID slapd

  sleep 5

  run docker exec $LDAP_CID ldapsearch -x -h ldap.example.org -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
  docker kill $LDAP_CID
  clear_containers_by_cid $LDAP_CID

  [ "$status" -eq 0 ]

  LDAP_CID=$(docker run -h ldap.example.org -e LDAP_TLS=false --volume $PWD/VOLUMES/database:/var/lib/ldap --volume $PWD/VOLUMES/config:/etc/ldap/slapd.d -d $NAME:$VERSION)
  wait_process_by_cid $LDAP_CID slapd

  sleep 5

  run docker exec $LDAP_CID ldapsearch -x -h ldap.example.org -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
  docker exec $LDAP_CID chown -R $UID:$UID /var/lib/ldap /etc/ldap/slapd.d
  docker kill $LDAP_CID
  clear_containers_by_cid $LDAP_CID
  rm -rf VOLUMES

  [ "$status" -eq 0 ]

}

@test "ldapsearch database with password provided from file" {

  echo "strongPassword" > $PWD/password.txt

  run_image -h ldap.osixia.net -e LDAP_ADMIN_PASSWORD_FILE=/run/secrets/admin_pw.txt --volume $PWD/password.txt:/run/secrets/admin_pw.txt
  wait_process slapd

  sleep 5

  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.osixia.net -b dc=example,dc=org -ZZ -D "cn=admin,dc=example,dc=org" -w strongPassword
  clear_container

  rm $PWD/password.txt

  [ "$status" -eq 0 ]
}


@test "ldapsearch new database with strict TLS" {

  run_image -h ldap.example.org
  wait_process slapd

  sleep 5

  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.example.org -b dc=example,dc=org -ZZ -D "cn=admin,dc=example,dc=org" -w admin
  clear_container

  [ "$status" -eq 0 ]

}

@test "ldapsearch new database with strict TLS and custom ca/crt" {

  run_image -h ldap.osixia.net -v $BATS_TEST_DIRNAME/ssl:/container/service/slapd/assets/certs -e LDAP_TLS_CRT_FILENAME=ldap-test.crt -e LDAP_TLS_KEY_FILENAME=ldap-test.key -e LDAP_TLS_CA_CRT_FILENAME=ca-test.crt
  wait_process slapd

  sleep 5

  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.osixia.net -b dc=example,dc=org -ZZ -D "cn=admin,dc=example,dc=org" -w admin
  clear_container

  [ "$status" -eq 0 ]

}

@test "ldapsearch new database with strict TLS and custom ca/crt and custom dhparam" {

  run_image -h ldap.osixia.net -v $BATS_TEST_DIRNAME/ssl:/container/service/slapd/assets/certs -e LDAP_TLS_CRT_FILENAME=ldap-test.crt -e LDAP_TLS_KEY_FILENAME=ldap-test.key -e LDAP_TLS_DH_PARAM_FILENAME=ldap-test.dhparam -e LDAP_TLS_CA_CRT_FILENAME=ca-test.crt
  wait_process slapd

  sleep 5

  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.osixia.net -b dc=example,dc=org -ZZ -D "cn=admin,dc=example,dc=org" -w admin
  clear_container

  [ "$status" -eq 0 ]

}

@test "ldapsearch existing hdb database and config" {

  run_image -h ldap.example.org -e LDAP_TLS=false -e LDAP_BACKEND=hdb -v $BATS_TEST_DIRNAME/database:/container/test/database -v $BATS_TEST_DIRNAME/config:/container/test/config
  wait_process slapd

  sleep 5

  run docker exec $CONTAINER_ID ldapsearch -x -h ldap.example.org -b dc=osixia,dc=net -D "cn=admin,dc=osixia,dc=net" -w admin
  clear_container

  [ "$status" -eq 0 ]

}


@test "replication with new databases and strict TLS" {

  tmp_file="$BATS_TMPDIR/docker-test"

  # replication ldap server
  LDAP_REPL_CID=$(docker run -h ldap2.example.org -e LDAP_REPLICATION=true -d $NAME:$VERSION)
  LDAP_REPL_IP=$(get_container_ip_by_cid $LDAP_REPL_CID)

  sleep 5

  # ldap server
  run_image -h ldap.example.org -e LDAP_REPLICATION=true

  # add route to hosts
  docker exec $CONTAINER_ID bash -c "echo $LDAP_REPL_IP ldap2.example.org >> /etc/hosts"
	docker exec $LDAP_REPL_CID bash -c "echo $CONTAINER_IP ldap.example.org >> /etc/hosts"

  # wait services on both servers
  wait_process slapd
  wait_process_by_cid $LDAP_REPL_CID slapd

  sleep 5

  # add user on ldap2.example.org
  docker exec $LDAP_REPL_CID ldapadd -x -D "cn=admin,dc=example,dc=org" -w admin -f /container/service/slapd/assets/test/new-user.ldif -h ldap2.example.org -ZZ

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
