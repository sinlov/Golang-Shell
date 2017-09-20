#!/usr/bin/env bash

checkFuncBack(){
  if [ $? -eq 0 ]; then
    echo "$1 checked"
  else
    echo "$1 check error exit"
    exit 1
  fi
}

shell_running_path=$(cd `dirname $0`; pwd)
android_sdk_download_url="https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz"
android_sdk_file_name="android-sdk_r24.4.1-linux.tgz"

android_sdk_tools_download_url="https://dl.google.com/android/repository/tools_r25.2.3-linux.zip"
android_sdk_tools_file_name="tools_r25.2.3-linux.zip"


# sudo apt-get install libc6-dev-i386 lib32z1 default-jdk
(while sleep 3; do echo "y"; done) | sudo apt-get install libc6-dev-i386 lib32z1

if [ -f "${shell_running_path}/${android_sdk_file_name}" ]; then
    tar tf ${shell_running_path}/${android_sdk_file_name}
    if [ $? -gt 0 ]; then
        echo -e "android sdk tar is broken
Path: ${shell_running_path}/${android_sdk_file_name}
just delete
"
        rm -rf ${shell_running_path}/${android_sdk_file_name}
        checkFuncBack "rm -rf ${shell_running_path}/${android_sdk_file_name}"
    fi
fi

which wget
checkFuncBack "check if have wget utils"

if [ ! -f "${shell_running_path}/${android_sdk_file_name}" ]; then
	wget ${android_sdk_download_url} -P ${shell_running_path}
	checkFuncBack "wget ${android_sdk_download_url} -P ${shell_running_path}"
	tar tf ${shell_running_path}/${android_sdk_file_name}
	checkFuncBack "tar tf ${shell_running_path}/${android_sdk_file_name}"
fi


if [ -f "${shell_running_path}/${android_sdk_tools_file_name}" ]; then
    unzip -t ${shell_running_path}/${android_sdk_tools_file_name}
    if [ $? -gt 0 ]; then
        echo -e "android tools zip is broken
Path: ${shell_running_path}/${android_sdk_tools_file_name}
just delete
"
        rm -rf ${shell_running_path}/${android_sdk_tools_file_name}
        checkFuncBack "rm -rf ${shell_running_path}/${android_sdk_tools_file_name}"
    fi
fi


if [ ! -f "${shell_running_path}/${android_sdk_tools_file_name}" ]; then
	wget ${android_sdk_tools_download_url} -P ${shell_running_path}
	checkFuncBack "wget ${android_sdk_tools_download_url} -P ${shell_running_path}"
	unzip -t ${shell_running_path}/${android_sdk_tools_file_name}
	checkFuncBack "unzip -t ${shell_running_path}/${android_sdk_tools_file_name}"
fi
