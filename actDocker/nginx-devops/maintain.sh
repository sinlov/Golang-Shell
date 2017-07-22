#!/usr/bin/env bash

echo "This script need sudo docker docker-compose"

which docker
docker version

which docker-compose
docker-compose version

sudo pwd
sudo docker-compose up -d
