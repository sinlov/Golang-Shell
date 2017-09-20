#!/usr/bin/env bash

# install sublime text 3 stable

# need sudo
echo "this script need sudo and install last sublimetext"
echo `sudo date +%Y%m%d-%H-%M-%S`

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install sublime-text
