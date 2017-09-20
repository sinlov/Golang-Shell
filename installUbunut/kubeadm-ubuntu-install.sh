#!/usr/bin/env bash

echo -e "This script install need sudo!\n"
# need sudo
echo `sudo date +%Y%m%d-%H-%M-%S`

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat << EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
# if not has docker just
# sudo apt-get install -y docker.io
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni

