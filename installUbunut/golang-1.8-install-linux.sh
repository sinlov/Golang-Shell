#!/bin/bash

# this script install golang-1.8

golang_download_url="http://www.golangtc.com/static/go/1.8/go1.8.linux-amd64.tar.gz"
golang_download_file="go1.8.linux-amd64.tar.gz"
golang_install_path="/usr/local/go"
install_temp_path="~/InstallTemp"

set_go_path_evn="$HOME/goPath"
set_path_file="$HOME/.bash_profile"

# start
shell_running_path=$(cd `dirname $0`; pwd)

echo -e "This script install need sudo!\n
Golang file from ${golang_download_url}
Env at ${set_path_file}
GOROOT -> ${golang_install_path}
GOPATH -> ${set_go_path_evn}
\n"

if [ -d "${golang_install_path}" ]; then
  echo "bin has install"
else
  # download and move to path
  if [ -d "${install_temp_path}" ]; then
    cd ${install_temp_path}
    if [ -d "${golang_download_file}" ]; then
      tar -C /usr/local -xzvf ${golang_download_file}
    else
      cd ~
      rm -rf ${install_temp_path}
      mkdir -p ${install_temp_path}
      cd ${install_temp_path}
      curl -O ${golang_download_url}
      tar -C /usr/local -xzvf ${golang_download_file}
    fi
  else
    mkdir -p ${install_temp_path}
    cd ${install_temp_path}
    curl -O ${golang_download_url}
    tar -C /usr/local -xzvf ${golang_download_file}
  fi
  echo -e "go install at ${golang_install_path}"
fi

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
GO_BIN_HOME=\$HOME/goPath/bin
export GO_BIN_HOME
export PATH=\$PATH:\$GO_BIN_HOM
EOF
echo -e "golang evn set at ${set_path_file}
You can change by your self or load path by
source ${set_path_file}"


echo -e "Want remove download catch at ${install_temp_path} y/n ?"
read wantRemove
if [ "${wantRemove}" == "y" ]; then
  rm -rf ${install_temp_path}
  echo -e "Remove ${install_temp_path} success"
fi

# end
cd ${shell_running_path}
