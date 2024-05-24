#!/bin/bash

export DOCKER=${DOCKER:-"docker"}
export BUILD_ARGS=""

if [ "$DOCKER" = "podman" ]; then
    export BUILD_ARGS="--format docker"
fi

$DOCKER build $BUILD_ARGS -f Dockerfile.nginx   --build-arg WWW_UID=33 --build-arg WWW_GID=33 -t hotcrp-nginx:latest ..
$DOCKER build $BUILD_ARGS -f Dockerfile.php-fpm --build-arg WWW_UID=33 --build-arg WWW_GID=33 -t hotcrp-php-fpm:latest ..
