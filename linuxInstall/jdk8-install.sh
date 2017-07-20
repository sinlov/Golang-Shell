#!/bin/bash

jdk_8_file_name="jdk-8u141-linux-x64.tag.gz"
jdk_8_path_shot="jdk-8u141-linux-x64"

jdk_8_install_path_head="$HOME/opt/"
set_path_file="$HOME/.bash_profile"

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

if [ ! -f "${jdk_8_file_name}" ]; then
    echo -e "Error can not find jdk install file ${jdk_8_file_name}"
    echo "you can download by http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html"
    echo "Error exit !"
    exit 1
fi

tar zxvf "./${jdk_8_file_name}"
checkFuncBack "tar unzip ./${jdk_8_file_name}"

mv "./${jdk_8_path_shot}" "${jdk_8_install_path_head}"
checkFuncBack "mv ./${jdk_8_path_shot} ${jdk_8_install_path_head}"

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