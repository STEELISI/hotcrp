# docker

This directory provides docker commands to setup a development environment

## Prerequisities

You need to have either docker or podman installed

If running docker, start the docker daemon and authorize your unix account to issue docker commands
If running podman, there are no additional steps needed

## Setup

If running podman, first set `export DOCKER=podman` in your environment

## Quick start

```bash
./build-containers.sh
START_MARIADB=1 ./start-containers.sh
./dbinit.sh # enter 'ok', 'root', 'root,' 'Y' in response to prompts
```

If this works, navigate your web browser to http://localhost:8080/testconf to see the hotcrp login
page

