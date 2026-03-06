#!/bin/bash

docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg CACHEBUST=$(date +%s) -t claude-code .
    