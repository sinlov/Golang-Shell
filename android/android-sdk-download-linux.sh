#!/bin/bash

checkFuncBack(){
  if [ $? -eq 0 ]; then
    echo "$1 checked"
  else
    echo "$1 check error exit"
    exit 1
  fi
}

which curl
checkFuncBack "check if have curl utils"

curl -O https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
curl -O https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
