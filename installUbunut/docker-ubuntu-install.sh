#!/usr/bin/env bash

# need sudo
echo "this script need sudo and install docker-ce"
install_docker_way="aliyun"
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
    echo "install pip"
    # use  Easy Install
    (while :; do echo 'y'; sleep 3; done) | sudo apt-get install python-setuptools python-dev build-essential
    sudo easy_install pip
    pip -V
    pip install --upgrade virtualenv
    virtualenv --version
fi


if [[ ${install_docker_way} == "aliyun" ]];then
    echo "install way by aliyun"
    # install docker-ce by aliyun
    sudo apt-get update
    sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get -y update
    sudo apt-get -y install docker-ce
else
    # install docker-ce
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get -y update
    sudo apt-get -y install docker-ce
fi
# check docker
echo "print docker version"
docker version

# install docker-compose
echo "print pip version"
pip -V
# sudo -H pip install docker-compose
sudo pip install docker-compose --ignore-installed texttable
echo "print docker-compose"
docker-compose version