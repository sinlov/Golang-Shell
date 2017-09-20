#!/bin/bash

android_sdk_file_name="android-sdk_r24.4.1-linux.tgz"
android_sdk_tools_file_name="tools_r25.2.3-linux.zip"

android_sdk_path_shot="android-sdk-linux"
android_sdk_tools_path_shot="tools"

android_install_path_head="$HOME/opt/"
androidInstallPath="${android_install_path_head}${android_sdk_path_shot}"
set_path_file="$HOME/.bash_profile"

shell_running_path=$(cd `dirname $0`; pwd)

checkFuncBack(){
  if [ $? -eq 0 ]; then
    echo "$1 checked"
  else
    echo "$1 check error exit"
    exit 1
  fi
}

echo "this script need use ${android_sdk_file_name} at now folder:"

if [ -n "${androidInstallPath}" ]; then
  echo -e "you set install path is ${androidInstallPath}"
else
  echo -e "you are not set install path, exit"
  exit 1
fi

if [ ! -f "${shell_running_path}/${android_sdk_file_name}" ]; then
    echo -e "Error can not find install file ${shell_running_path}/${android_sdk_file_name}"
    echo "you can download by https://developer.android.google.cn/studio/releases/sdk-tools.html"
    echo "Error exit !"
    exit 1
fi

if [ -d "${shell_running_path}/${android_sdk_path_shot}" ]; then
    echo -e "catch android sdk path at
path: ${shell_running_path}/${android_sdk_path_shot}
try to remove
"
    rm -rf ${shell_running_path}/${android_sdk_path_shot}
    checkFuncBack "rm -rf ${shell_running_path}/${android_sdk_path_shot}"
fi

if [ -d "${androidInstallPath}" ]; then
  echo -e "want install android sdk at
path: ${androidInstallPath}
exist exit install 0"
    exit 0
fi

which tar
checkFuncBack "check if have unzip tar tools"

tar tf ${shell_running_path}/${android_sdk_file_name}
checkFuncBack "tar tf ${shell_running_path}/${android_sdk_file_name}"

tar zxvf "${shell_running_path}/${android_sdk_file_name}" -C "${shell_running_path}"
checkFuncBack "tar zxvf "${shell_running_path}/${android_sdk_file_name}" -C "${shell_running_path}""

if [ ! -d "${android_install_path_head}" ]; then
    echo -e "can not find ${android_install_path_head} just mark it"
    mkdir -p ${android_install_path_head}
    checkFuncBack "mkdir -p ${android_install_path_head}"
fi

mv "${shell_running_path}/${android_sdk_path_shot}" "${android_install_path_head}"
checkFuncBack "mv ${shell_running_path}/${android_sdk_path_shot} ${android_install_path_head}"

# check install path again
if [ ! -d "${androidInstallPath}" ]; then
  echo -e "your install path is empty, exit"
  exit 1
fi

echo -e "This script set event of jdk!
Env set file path: ${set_path_file}
ANDROID_HOME -> ${androidInstallPath}
\n"

if [ ! -f "${set_path_file}" ]; then
  cat > "${set_path_file}" << EOF
# environment set by https://github.com/sinlov/Golang-Shell

EOF
fi

cat >> "${set_path_file}" << EOF

# set android environment
ANDROID_HOME=${androidInstallPath}
export ANDROID_HOME
export PATH=\${ANDROID_HOME}/tools:\${ANDROID_HOME}/platform-tools:\${ANDROID_HOME}/build-tools/24.0.0:\$PATH
EOF
echo -e "android evn set at ${set_path_file}
You can change by your self vim ${set_path_file}
load path by source ${set_path_file}"


echo "start clean tmp"
if [ -d ${shell_running_path}${android_sdk_path_shot} ]; then
    rm -rf ${shell_running_path}${android_sdk_path_shot}
    checkFuncBack "rm -rf ${shell_running_path}${android_sdk_path_shot}"
fi
echo "clean tmp success"