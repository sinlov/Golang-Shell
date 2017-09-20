#!/bin/bash

# this script install golang at

shell_running_path=$(cd `dirname $0`; pwd)

checkFuncBack(){
  if [ $? -eq 0 ]; then
    echo "$1 checked"
  else
    echo "$1 check error exit"
    exit 1
  fi
}

golang_download_url="https://www.golangtc.com/static/go/1.9/go1.9.linux-amd64.tar.gz"
golang_download_file="go1.9.linux-amd64.tar.gz"
golang_tar_path_shot="go1.9"
golang_install_path_head="$HOME/opt/"
golang_install_path="${golang_install_path_head}${golang_tar_path_shot}"

set_go_path_evn="$HOME/goPath"
set_path_file="$HOME/.bash_profile"

# start

echo -e "This script install need sudo!\n
Golang version ${golang_tar_path_shot}
Golang file from ${golang_download_url}
Env at ${set_path_file}
GOROOT -> ${golang_install_path}
GOPATH -> ${set_go_path_evn}
\n"

if [ -d "${shell_running_path}/${golang_tar_path_shot}" ]; then
    echo "${shell_running_path}/${golang_tar_path_shot} has exist exit try to delete"
    rm -rf "${shell_running_path}/${golang_tar_path_shot}"
    checkFuncBack "rm -rf ${shell_running_path}/${golang_tar_path_shot}"
fi


if [ ! -n "${golang_install_path}" ]; then
  echo -e "you are not set golang install path, exit"
  exit 1
fi

if [ -d "${golang_install_path}" ];then
    echo "has been install golang exit"
    rm -rf "${shell_running_path}/${golang_tar_path_shot}"
    checkFuncBack "rm -rf ${shell_running_path}/${golang_tar_path_shot}"
    exit 0
fi

if [ -f "${shell_running_path}/${golang_download_file}" ];then
  which tar
  checkFuncBack "check tar"
  tar jtf ${shell_running_path}/${golang_download_file}
  if [ $? -gt 0 ]; then
    echo -e "download golang file is broken just delete\n-> path: ${shell_running_path}/${golang_download_file}"
    rm ${shell_running_path}/${golang_download_file}
    checkFuncBack "rm ${shell_running_path}/${golang_download_file}"
  fi
fi

if [ ! -f "${shell_running_path}/${golang_download_file}" ];then
  which wget
  checkFuncBack "check wget"
  wget ${golang_download_url} -P ${shell_running_path}
  checkFuncBack "wget ${golang_download_url} -P ${shell_running_path}"
# curl -O ${golang_download_url}
# download_path="`pwd`/${golang_download_file}"
# mv ${download_path} ${shell_running_path}
# checkFuncBack "mv ${download_path} ${shell_running_path}"
fi

tar zxvf "${shell_running_path}/${golang_download_file}" -C "${shell_running_path}"
checkFuncBack "tar zxvf "${shell_running_path}/${golang_download_file}" -C "${shell_running_path}""

if [ ! -d "${golang_install_path_head}" ]; then
    echo -e "can not find path ${golang_install_path_head} just mark it"
    mkdir -p ${golang_install_path_head}
    checkFuncBack "mkdir -p ${golang_install_path_head}"
fi

mv ${shell_running_path}/${golang_tar_path_shot} ${golang_install_path}
checkFuncBack "mv ${shell_running_path}/${golang_tar_path_shot} ${golang_install_path}"

# check golang install path again
if [ ! -f "${set_path_file}" ]; then
  cat > "${set_path_file}" << EOF
# environment set by https://github.com/sinlov/Golang-Shell

EOF
fi

echo -e "golang evn set at ${set_path_file}
You can change by your self(empty is not change):"
read customSetPathFile
if [ ! -n "$customSetPathFile" ]; then
  set_path_file="${customSetPathFile}"
fi

echo "now path file at ${set_path_file}"

if [ ! -d "${set_go_path_evn}" ]; then
  mkdir -p ${set_go_path_evn}
fi

cat >> "${set_path_file}" << EOF

# golang evn set
export GOROOT=${golang_install_path}
export PATH=\$PATH:\$GOROOT/bin
export GOPATH=${set_go_path_evn}
export PATH=\$PATH:${set_go_path_evn}/bin
GO_BIN_HOME=${set_go_path_evn}/bin
export GO_BIN_HOME
export PATH=\$PATH:\$GO_BIN_HOM
EOF
echo -e "golang evn set at ${set_path_file}
You can change by your self or load path by
source ${set_path_file}"

echo "start clean tmp"
if [ -d ${shell_running_path}${golang_tar_path_shot} ]; then
    rm -rf ${shell_running_path}${golang_tar_path_shot}
    checkFuncBack "rm -rf ${shell_running_path}${golang_tar_path_shot}"
fi
echo "clean tmp success"

#echo -e "Want remove download catch at ${shell_running_path}/${golang_download_file} y/n ?"
#read wantRemove
#if [ "${wantRemove}" == "y" ]; then
#  rm -f ${shell_running_path}/${golang_download_file}
#  checkFuncBack "rm -f ${shell_running_path}/${golang_download_file}"
#  echo -e "Remove rm -f ${shell_running_path}/${golang_download_file} success"
#fi
