#!/usr/bin/env bash

checkFuncBack(){
  if [ $? -eq 0 ]; then
    echo "$1 checked"
  else
    echo "$1 check error exit"
    exit 1
  fi
}

echo "This script need set ANDROID_HOME and event be right!"

if [ -f "$HOME/.bash_profile" ]; then
	source $HOME/.bash_profile
fi

check_android=$(echo $ANDROID_HOME)
if [ ! -n "${check_android}" ]; then
    echo "you have not set ANDROID_HOME"
    exit 1
else
    echo "ANDROID_HOME:${check_android}"
fi

which java
checkFuncBack "java evn"
which android
checkFuncBack "android evn"
#
#
cp android_sdk_components.env "${ANDROID_HOME}/android_sdk_components.env"
(while :; do echo 'y'; sleep 3; done) | android update sdk --no-ui --all --filter "$(cat ${ANDROID_HOME}/android_sdk_components.env)"
