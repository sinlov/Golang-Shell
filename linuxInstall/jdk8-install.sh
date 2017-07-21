#!/bin/bash

jdk_8_file_name="jdk-8u141-linux-x64.tar.gz"
jdk_8_path_shot="jdk1.8.0_141"

jdk_8_install_path_head="$HOME/opt/"
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

echo "this script need use ${jdk_8_file_name} at now folder:"
pwd

if [ ! -f "${shell_running_path}/${jdk_8_file_name}" ]; then
    echo -e "Error can not find jdk install file ${shell_running_path}/${jdk_8_file_name}"
    echo "you can download by http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html"
    echo "Error exit !"
    exit 1
fi

if [ -d "${shell_running_path}/${jdk_8_path_shot}" ]; then
    echo "Now"
    pwd
    echo "${shell_running_path}/${jdk_8_path_shot} has exist exit!"
    exit 1
fi


which tar
checkFuncBack "check if have unzip tar"

tar zxvf "${shell_running_path}/${jdk_8_file_name}" -C "${shell_running_path}"
checkFuncBack "tar zxvf "${shell_running_path}/${jdk_8_file_name}" -C "${shell_running_path}""

if [ ! -d "${jdk_8_install_path_head}" ]; then
    echo -e "can not find ${jdk_8_install_path_head} just mark it"
    mkdir -p ${jdk_8_install_path_head}
    checkFuncBack "mkdir -p ${jdk_8_install_path_head}"
fi

mv "${shell_running_path}/${jdk_8_path_shot}" "${jdk_8_install_path_head}${jdk_8_path_shot}"
checkFuncBack "mv "${shell_running_path}/${jdk_8_path_shot}" "${jdk_8_install_path_head}${jdk_8_path_shot}""

jdkInstallPath="${jdk_8_install_path_head}${jdk_8_path_shot}"

if [ -n "${jdkInstallPath}" ]; then
  echo -e "you set install jdk path is ${jdkInstallPath}"
else
  echo -e "you are not set jdk install path, exit"
  exit 1
fi

# check jdk install path
if [ ! -d "${jdkInstallPath}" ]; then
  echo -e "you jdk install path is empty, exit"
  exit 1
fi

echo -e "This script set event of jdk!
Env set file path: ${set_path_file}
JAVA_HOME -> ${jdkInstallPath}
\n"

if [ ! -f "${set_path_file}" ]; then
  cat > "${set_path_file}" << EOF
# environment set by https://github.com/sinlov/Golang-Shell

EOF
fi

cat >> "${set_path_file}" << EOF

# set jdk environment
export JAVA_HOME=${jdkInstallPath}
export PATH=\$JAVA_HOME/bin:\$PATH
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
EOF
echo -e "jdk evn set at ${set_path_file}
You can change by your self vim ${set_path_file}
load path by source ${set_path_file}"


echo "start clean tmp"
if [ -d ${shell_running_path}${jdk_8_path_shot} ]; then
    rm -rf ${shell_running_path}${jdk_8_path_shot}
    checkFuncBack "rm -rf ${shell_running_path}${jdk_8_path_shot}"
fi
echo "start clean tmp success"