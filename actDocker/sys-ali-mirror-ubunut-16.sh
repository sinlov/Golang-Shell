#!/bin/bash

if [ ! -n "$1" ]; then
    echo -e "please input ali mirror code: like \[atnqc8bo\]"
    exit 1
fi

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/mirror.conf <<-'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon -H fd:// --registry-mirror=https://{$1}.mirror.aliyuncs.com
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
