#!/bin/bash

gradle_version="2.14.1"

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
    echo "${shell_running_path}/${gradle_bin_path_shot} has exist exit!"
    exit 1
fi

if [ ! -f "${shell_running_path}/${gradle_bin_file_name}" ]; then
    echo "can not found file ${shell_running_path}/${gradle_bin_file_name}"
    echo "try to use ${gradle_download_url}"
    wget "${gradle_download_url}"
    checkFuncBack "wget ${gradle_download_url}"
fi

unzip "${shell_running_path}/${gradle_bin_file_name}" -d "${shell_running_path}${gradle_bin_path_shot}"
checkFuncBack ""${shell_running_path}/${gradle_bin_file_name}" -d "${shell_running_path}""

mv "${shell_running_path}/${gradle_bin_path_shot}" "${gradle_install_path_head}"
checkFuncBack "mv ${shell_running_path}/${gradle_bin_path_shot} ${gradle_install_path_head}"

gradleInstallPath="${gradle_install_path_head}${gradle_bin_path_shot}"

if [ -n "${gradleInstallPath}" ]; then
  echo -e "you set install gradle path is ${gradleInstallPath}"
else
  echo -e "you are not set gradle install path, exit"
  exit 1
fi

# check gradle install path
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
rm -rf "${shell_running_path}/${gradle_bin_path_shot}"
checkFuncBack "rm -rf ${shell_running_path}/${gradle_bin_path_shot}"
echo "start clean tmp success"
