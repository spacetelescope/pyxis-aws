#!/bin/bash

source ./config.sh

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $REPO_URI

docker push $DOCKERIMAGE
