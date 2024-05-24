#!/bin/bash

export DOCKER=${DOCKER:-"docker"}
export START_MARIADB=${START_MARIADB:-0}

$DOCKER network inspect hotcrp &> /dev/null
if [ $? -ne 0 ]; then
    $DOCKER network create hotcrp
fi

# mysql
if [ ${START_MARIADB} -eq 1 ]; then
    $DOCKER rm -f mariadb
    $DOCKER run --rm -d --network hotcrp \
        --env MARIADB_ROOT_PASSWORD=root \
        --name mariadb \
        docker.io/library/mariadb:11.3.2
fi

# php-fpm
$DOCKER rm -f php-fpm
$DOCKER run --rm -d --network hotcrp \
    --name php-fpm \
    localhost/hotcrp-php-fpm:latest

#nginx
$DOCKER rm -f nginx
$DOCKER run --rm -d --network hotcrp \
    --name nginx \
    -p 8080:80 \
    localhost/hotcrp-nginx:latest
