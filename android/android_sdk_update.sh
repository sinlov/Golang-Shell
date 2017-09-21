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


# update by ${shell_running_path}/android_sdk_components.env
echo "update by ${shell_running_path}/android_sdk_components.env"
cp ${shell_running_path}/android_update_sdk.sh ${ANDROID_HOME}/android_update_sdk.sh
cp ${shell_running_path}/android_update_support.sh ${ANDROID_HOME}/android_update_support.sh
cp ${shell_running_path}/android_sdk_components.env ${ANDROID_HOME}/android_sdk_components.env
(while :; do echo 'y'; sleep 3; done) | android update sdk --no-ui --all --filter "$(cat ${ANDROID_HOME}/android_sdk_components.env)"

echo -e "update success!
== After install you must use ==

sudo chown -R User:User $ANDROID_HOME/

fix $ANDROID_HOME build Permission issues

== force update full SDK ==
you can edit
${ANDROID_HOME}/android_sdk_components.env
then run
${ANDROID_HOME}/android_update_sdk.sh
for update

== fix support error ==
you can edit
${ANDROID_HOME}/android_update_support.env
then run
${ANDROID_HOME}/android_update_support.sh
this script can fix com.android.support.constraint:constraint-layout error
"