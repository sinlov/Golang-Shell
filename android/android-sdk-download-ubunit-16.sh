#!/bin/bash

checkFuncBack(){
  if [ $? -eq 0 ]; then
    echo "$1 checked"
  else
    echo "$1 check error exit"
    exit 1
  fi
}

shell_running_path=$(cd `dirname $0`; pwd)

# sudo apt-get install libc6-dev-i386 lib32z1 default-jdk
(while sleep 3; do echo "y"; done) | sudo apt-get install libc6-dev-i386 lib32z1

which curl
checkFuncBack "check if have curl utils"

curl -O ${shell_running_path} https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
checkFuncBack "curl -O ${shell_running_path} https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz"
curl -O ${shell_running_path} https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
checkFuncBack "curl -O ${shell_running_path} https://dl.google.com/android/repository/tools_r25.2.3-linux.zip"
