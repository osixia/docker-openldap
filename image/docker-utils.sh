#!/usr/bin/env bash

debug_container=0

#DOCKER_REGISTRY_LABEL=org-dettonville-labs
DOCKER_REGISTRY_LABEL=localhost
DOCKERFILE=Dockerfile

## ref: https://hub.docker.com/r/tartarefr/docker-cobbler/
#HOST_IP_ADDR=$(hostname --ip-address)
HOST_IP_ADDR=$(hostname --ip-address | awk '{print $1}')

HTTPD_LOG_DIR="/var/log/httpd"

usage() {
    echo "" 1>&2
    echo "Usage: ${0} [options] command container_name" 1>&2
    echo "" 1>&2
    echo "  Options:" 1>&2
    echo "     -f dockerfile : set dockerfile used, defaults to 'Dockerfile'" 1>&2
    echo "" 1>&2
    echo "  Required:" 1>&2
    echo "     container_name:   container name" 1>&2
    echo "     command:    build (builds docker image)" 1>&2
    echo "                 clean-build (cleans existing image and rebuilds)" 1>&2
    echo "                 deploy (deploys image to docker repo)" 1>&2
    echo "                 run (restart container)" 1>&2
    echo "                 restart (restart container)" 1>&2
    echo "                 debug (run bash in container to debug)" 1>&2
    echo "                 attach (attach to existing container and run bash)" 1>&2
    echo "                 stop (stop container)" 1>&2
    echo "                 tail-accesslog (tails apache access log from running container)" 1>&2
    echo "                 tail-errorlog (tails apache error log from running container)" 1>&2
    echo "                 fetch-accesslog (fetches a copy of the apache access log from running container)" 1>&2
    echo "                 fetch-errorlog (fetches a copy of the apache error log from running container)" 1>&2
    echo "" 1>&2
    echo "  Examples:" 1>&2
    echo "     ${0} build docker-openldap"
    echo "     ${0} build localhost/ubuntu:bionic"
    echo "     ${0} build docker-openldap-orig"
    echo "     ${0} -f Dockerfile build docker-openldap"
    echo "     ${0} restart docker-cobbler"
    echo "     ${0} run docker-openldap"
    echo "     ${0} attach docker-openldap"
    echo "     ${0} debug docker-openldap"
    exit 1
}

build_image() {

    DOCKER_IMAGE_NAME=$1
    CLEAN_BUILD=${2-0}

#    DOCKER_IMAGE_NAME="${DOCKER_REGISTRY_LABEL}/${DOCKER_IMAGE_NAME}"
    CONTAINER_NAME="${DOCKER_IMAGE_NAME}"

    if [ "$(docker ps -qa --no-trunc --filter name=^/${CONTAINER_NAME}$)" ]; then
        if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
            docker stop ${CONTAINER_NAME}
        fi
        docker rm ${CONTAINER_NAME}
    fi

    if [[ ${CLEAN_BUILD} -ne 0 ]]; then
        if [[ "$(docker images -q ${DOCKER_IMAGE_NAME} 2> /dev/null)" ]]; then
            docker rmi ${DOCKER_IMAGE_NAME}
        fi
    fi

    CURR_DIR=`pwd`
    git pull

#    docker build -t ${DOCKER_IMAGE_NAME} .
#    docker build -t cobbler:latest . -f Dockerfile.build
    docker build -t ${DOCKER_IMAGE_NAME} . -f ${DOCKERFILE}

}

deploy_image() {
    DOCKER_IMAGE_NAME=$1

#    DOCKER_IMAGE_NAME="${DOCKER_REGISTRY_LABEL}/${DOCKER_IMAGE_NAME}"
    #DOCKER_REPO_URL="artifactory.example.local:6555"
    DOCKER_REPO_URL="localhost:5000"

    docker tag ${DOCKER_IMAGE_NAME} ${DOCKER_REPO_URL}/${DOCKER_IMAGE_NAME}

    docker login "https://${DOCKER_REPO_URL}"
    docker push ${DOCKER_REPO_URL}/${DOCKER_IMAGE_NAME}

}


attach_container() {

    DOCKER_IMAGE_NAME=$1
    DOCKER_APP_NAME="$( cut -d ':' -f 1 <<< ${DOCKER_IMAGE_NAME} )"

#    DOCKER_IMAGE_NAME="${DOCKER_REGISTRY_LABEL}/${DOCKER_APP_NAME}"
    CONTAINER_NAME="${DOCKER_APP_NAME}"
    DATA_CONTAINER_NAME="${DOCKER_APP_NAME}-data"

#    docker exec -it loving_heisenberg /bin/bash
    docker exec -it ${CONTAINER_NAME} /bin/bash

}

restart_container() {

    DOCKER_IMAGE_NAME=$1
    DOCKER_APP_NAME="$( cut -d ':' -f 1 <<< ${DOCKER_IMAGE_NAME} )"
    DEBUG=${2-0}

#    DOCKER_IMAGE_NAME="${DOCKER_REGISTRY_LABEL}/${DOCKER_APP_NAME}"
    CONTAINER_NAME="${DOCKER_APP_NAME}"
    DATA_CONTAINER_NAME="${DOCKER_APP_NAME}-data"

    if [ ! "$(docker ps -qa --no-trunc --filter name=^/${DATA_CONTAINER_NAME}$)" ]; then
        docker create --name ${DATA_CONTAINER_NAME} --volume "${PWD}/.conf/":/opt/proxy-conf busybox /bin/true
    fi

    if [ "$(docker ps -qa --no-trunc --filter name=^/${CONTAINER_NAME}$)" ]; then
        if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
            docker stop ${CONTAINER_NAME}
            echo "container stopped"
        fi
        docker rm ${CONTAINER_NAME}
    fi

    if [[ ${DEBUG} -eq 1 ]]; then
        echo "debugging container - starting bash inside container:"
        docker run --name ${CONTAINER_NAME} \
            --volume "${PWD}/.certs":/opt/ssl/ \
            --volumes-from ${DATA_CONTAINER_NAME} \
            --net=host \
            -it --entrypoint /bin/bash ${DOCKER_IMAGE_NAME}
        exit 0
    elif [[ ${DEBUG} -eq 2 ]]; then
#        docker exec -it loving_heisenberg /bin/bash
        docker exec -it ${CONTAINER_NAME} /bin/bash
        exit 0
    fi

    docker run --name ${CONTAINER_NAME} \
        --volume "${PWD}/.certs":/opt/ssl/ \
        --volumes-from ${DATA_CONTAINER_NAME} \
        --net=host \
        -d ${DOCKER_IMAGE_NAME}

    echo "started container"
    echo "tailing container stdout..."

    docker logs -f ${CONTAINER_NAME}

}


stop_container() {

    DOCKER_IMAGE_NAME=$1
    DOCKER_APP_NAME="$( cut -d ':' -f 1 <<< ${DOCKER_IMAGE_NAME} )"

    CONTAINER_NAME="${DOCKER_APP_NAME}"

    if [ "$(docker ps -qa -f name=^/${CONTAINER_NAME}$)" ]; then
        #if [ "$(docker ps -q -f status=exited -f name=${CONTAINER_NAME})" ]; then
        if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
            docker stop ${CONTAINER_NAME}
            echo "container stopped"
        else
            echo "container not running"
        fi
    fi
}


tail_log() {

    DOCKER_IMAGE_NAME=$1
    DOCKER_APP_NAME="$( cut -d ':' -f 1 <<< ${DOCKER_IMAGE_NAME} )"
    HTTPD_LOG_FILE=$2

    CONTAINER_NAME="${DOCKER_APP_NAME}"

    docker exec -it ${CONTAINER_NAME} tail -50f ${HTTPD_LOG_FILE}
}

fetch_log() {

    DOCKER_IMAGE_NAME=$1
    DOCKER_APP_NAME="$( cut -d ':' -f 1 <<< ${DOCKER_IMAGE_NAME} )"
    HTTPD_LOG_FILE=$2
    FETCHED_LOG_FILE=$(basename ${HTTPD_LOG_FILE})

    CONTAINER_NAME="${DOCKER_APP_NAME}"

    docker cp ${CONTAINER_NAME}:${HTTPD_LOG_FILE} ${FETCHED_LOG_FILE}
}


while getopts "f:hx" opt; do
    case "${opt}" in
        f) DOCKERFILE="${OPTARG}" ;;
        x) debug_container=1 ;;
        h) usage 1 ;;
        \?) usage 2 ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ $# != 2 ]; then
    echo "required command and image arguments not specified" >&2
    usage
fi

command=$1
docker_image_name=$2

case "${command}" in
    "build")
        build_image ${docker_image_name} 0
        ;;
    "clean-build")
        build_image ${docker_image_name} 1
        ;;
    "deploy")
        deploy_image ${docker_image_name}
        ;;
    "restart"|"run")
        restart_container ${docker_image_name} $debug_container
        ;;
    "debug")
        debug_container=1
        restart_container ${docker_image_name} $debug_container
        ;;
    "attach")
        attach_container ${docker_image_name}
        ;;
    "stop")
        stop_container ${docker_image_name}
        ;;
    "tail-accesslog")
        tail_log ${docker_image_name} "${HTTPD_LOG_DIR}/access.log"
        ;;
    "tail-errorlog")
        tail_log ${docker_image_name} "${HTTPD_LOG_DIR}/error.log"
        ;;
    "fetch-accesslog")
        fetch_log ${docker_image_name} "${HTTPD_LOG_DIR}/access.log"
        ;;
    "fetch-errorlog")
        fetch_log ${docker_image_name} "${HTTPD_LOG_DIR}/error.log"
        ;;
    *)
        echo "Invalid command: $command" >&2
        usage
        ;;
esac
