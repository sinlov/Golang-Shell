#!/bin/bash

gradle_version="3.3"

gradle_bin_file_name="gradle-${gradle_version}-bin.zip"
gradle_bin_path_shot="gradle-${gradle_version}"
gradle_download_url="https://services.gradle.org/distributions/gradle-${gradle_version}-bin.zip"

gradle_install_path_head="$HOME/opt/"
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

echo "Try to install gradle ${gradle_version}"
echo "this script can use ${gradle_bin_file_name} at ${shell_running_path} folder:"
pwd
echo "Or use download url"
echo "If want change gradle version just change see https://gradle.org/releases/"
echo -e "\nHave fine!\n"

which unzip
checkFuncBack "check if have unzip utils"
which wget
checkFuncBack "check if have wget utils"

if [ -d "${shell_running_path}/${gradle_bin_path_shot}" ]; then
    echo "Now"
    pwd
    echo "${shell_running_path}/${gradle_bin_path_shot} has exist, try to remove"
    rm -rf ${shell_running_path}/${gradle_bin_path_shot}
    checkFuncBack "rm -rf ${shell_running_path}/${gradle_bin_path_shot}"
fi

gradleInstallPath="${gradle_install_path_head}${gradle_bin_path_shot}"

if [ -n "${gradleInstallPath}" ]; then
  echo -e "you set install gradle path is ${gradleInstallPath}"
else
  echo -e "you are not set gradle install path, exit"
  exit 1
fi

if [ -d "${gradleInstallPath}" ]; then
    echo -e "Just isntall gradle install at path: ${gradleInstallPath}, exit"
  exit 0
fi

if [ -f "${shell_running_path}/${gradle_bin_file_name}" ]; then
    unzip -t ${shell_running_path}/${gradle_bin_file_name}
    if [ ! $? -eq 0 ]; then
      echo "gradle download zip is broken just remove"
      rm ${shell_running_path}/${gradle_bin_file_name}
      checkFuncBack "rm ${shell_running_path}/${gradle_bin_file_name}"
      echo "bin file is broken so try to use ${gradle_download_url}"
      wget "${gradle_download_url}" -P ${shell_running_path}
      checkFuncBack "wget "${gradle_download_url}" -P ${shell_running_path}"
    fi
else
  echo "can not found file ${shell_running_path}/${gradle_bin_file_name}"
  echo "try to use ${gradle_download_url}"
  wget "${gradle_download_url}" -P ${shell_running_path}
  checkFuncBack "wget "${gradle_download_url}" -P ${shell_running_path}"
fi

unzip ${shell_running_path}/${gradle_bin_file_name} -d ${shell_running_path}
checkFuncBack "unzip ${shell_running_path}/${gradle_bin_file_name} -d ${shell_running_path}"

if [ ! -d "${gradle_install_path_head}" ]; then
    echo -e "can not find ${gradle_install_path_head} just mark it"
    mkdir -p ${gradle_install_path_head}
    checkFuncBack "mkdir -p ${gradle_install_path_head}"
fi

mv "${shell_running_path}/${gradle_bin_path_shot}" "${gradle_install_path_head}"
checkFuncBack "mv ${shell_running_path}/${gradle_bin_path_shot} ${gradle_install_path_head}"

# check gradle install path again
if [ ! -d "${gradleInstallPath}" ]; then
  echo -e "you gradle install path is empty, exit"
  exit 1
fi

echo -e "This script set event of gradle!
Env set file path: ${set_path_file}
gradle_HOME -> ${gradleInstallPath}
\n"

if [ ! -f "${set_path_file}" ]; then
  cat > "${set_path_file}" << EOF
# environment set by https://github.com/sinlov/Golang-Shell

EOF
fi

cat >> "${set_path_file}" << EOF

# set gradle environment
export gradle_HOME=${gradleInstallPath}
export PATH=\$gradle_HOME/bin:\$PATH
EOF
echo -e "gradle evn set at ${set_path_file}
You can change by your self vim ${set_path_file}
load path by source ${set_path_file}"


echo "start clean tmp"
if [ -d ${shell_running_path}${gradle_bin_path_shot} ]; then
    rm -rf ${shell_running_path}${gradle_bin_path_shot}
    checkFuncBack "rm -rf ${shell_running_path}${gradle_bin_path_shot}"
fi
echo "start clean tmp success"
