#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install docker.io
which pip
pip -V
sudo -H pip install docker-compose
docker-compose version