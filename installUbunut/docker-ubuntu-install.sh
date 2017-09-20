#!/usr/bin/env bash

# need sudo
echo "this script need sudo and install docker-ce"
echo `sudo date +%Y%m%d-%H-%M-%S`

checkFuncBack(){
  if [ $? -eq 0 ]; then
    echo "$1 checked"
  else
    echo "$1 check error exit"
    exit 1
  fi
}
sudo apt-get update

which pip
if [ $? -gt 0 ]; then
	python -V
	which python
	# use  Easy Install
	(while :; do echo 'y'; sleep 3; done) | sudo apt-get install python-setuptools python-dev build-essential
	sudo easy_install pip
	pip -V
	pip install --upgrade virtualenv
	virtualenv --version
fi

# install docker-ce
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update
sudo apt-get install docker-ce
# install docker-compose

pip -V
sudo -H pip install docker-compose
echo "print docker-compose"
docker-compose version