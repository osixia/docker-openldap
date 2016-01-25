setup() {
  IMAGE_NAME="$NAME:$VERSION"
}

# function relative to the current container / image
build_image() {
  #disable outputs
  docker build -t $IMAGE_NAME $BATS_TEST_DIRNAME/../image &> /dev/null
}

run_image() {
  CONTAINER_ID=$(docker run $@ -d $IMAGE_NAME)
  CONTAINER_IP=$(get_container_ip_by_cid $CONTAINER_ID)
}

start_container() {
  start_containers_by_cid $CONTAINER_ID
}

stop_container() {
  stop_containers_by_cid $CONTAINER_ID
}

remove_container() {
 remove_containers_by_cid $CONTAINER_ID
}

clear_container() {
  stop_containers_by_cid $CONTAINER_ID
  remove_containers_by_cid $CONTAINER_ID
}

is_service_running() {
  is_service_running_by_cid $CONTAINER_ID $1
}

is_file_exists() {
  is_file_exists_by_cid $CONTAINER_ID $1
}

wait_service() {
  wait_service_by_cid $CONTAINER_ID $@
}


# generic functions
get_container_ip_by_cid() {
  local IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $1)
  echo "$IP"
}

start_containers_by_cid() {
  for cid in "$@"
  do
    #disable outputs
    docker start $cid &> /dev/null
  done
}

stop_containers_by_cid() {
  for cid in "$@"
  do
    #disable outputs
    docker stop $cid &> /dev/null
  done
}

remove_containers_by_cid() {
  for cid in "$@"
  do
    #disable outputs
    docker rm $cid &> /dev/null
  done
}

clear_containers_by_cid() {
  stop_containers_by_cid $@
  remove_containers_by_cid $@
}

is_service_running_by_cid() {
  docker exec $1 ps cax | grep $2  > /dev/null
}

is_file_exists_by_cid() {
  docker exec $1 cat $2 > /dev/null 2>&1
}

wait_service_by_cid() {

  cid=$1

  # first wait image init end
  while ! is_file_exists_by_cid $cid /container/run/state/startup-done
  do
    sleep 0.5
  done

  for service in "${@:2}"
  do
    # wait service
    while ! is_service_running_by_cid $cid $service
    do
      sleep 0.5
    done
  done
}
