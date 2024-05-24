#!/bin/bash

# This will prompt you interactively; enter:
# - ok
# - root
# - root
# - Y
#
# to initialize

export DOCKER=${DOCKER:-"docker"}

$DOCKER run --network hotcrp --rm -it --name dbinit \
    localhost/hotcrp-dbinit:latest \
    /hotcrp/lib/createdb.sh --host mariadb --user root --password root
