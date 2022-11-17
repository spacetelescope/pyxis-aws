#!/bin/bash

source ./config.sh

docker build -f Dockerfile -t $DOCKERIMAGE .

docker image ls
