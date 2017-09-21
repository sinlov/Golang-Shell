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

echo "This script need set ANDROID_HOME and event be right!"

update_support_list="extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"

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


# add licenses
if [ ! -d "${ANDROID_HOME}/licenses" ];then
	mkdir -p ${ANDROID_HOME}/licenses
	checkFuncBack "mkdir -p ${ANDROID_HOME}/licenses"
fi

if [ ! -f "${ANDROID_HOME}/licenses/android-sdk-license" ];then
	cat > "${ANDROID_HOME}/licenses/android-sdk-license" << EOF

8933bad161af4178b1185d1a37fbf41ea5269c55
EOF
fi

install_software_name="android support update"
start_install_time=$(date "+%Y-%m-%d %H:%M:%S")
echo -e "
-> Just start ${start_install_time}
"

if [ ! -d "$HMOE/.android" ]; then
    mkdir -p "$HOME/.android"
fi

if [ ! -f "$HOME/.android/repositories.cfg" ];then
    touch $HOME/.android/repositories.cfg
fi

# update by ${ANDROID_HOME}/android_sdk_components.env
echo "update by ${ANDROID_HOME}/tools/bin/sdkmanager"
echo -e "update list is
${update_support_list}
"
${ANDROID_HOME}/tools/bin/sdkmanager ${update_support_list}

end_install_time=$(date "+%Y-%m-%d %H:%M:%S")
echo -e "====== End [ ${install_software_name} ] at: ${end_install_time} ======"
time_use=$((`date +%s -d "${end_install_time}"` - `date +%s -d "${start_install_time}"`))
time_use_format=$(date -d "1970-01-01 CST ${time_use} seconds" "+%T")
echo -e "
-> total use time ${time_use_format}
"
