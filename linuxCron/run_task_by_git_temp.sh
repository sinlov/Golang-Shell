#!/usr/bin/env bash

# use at crontab -e
# 0 0 * * * [shell cli]
# like 0 0 * * * each day
# like 0 * * * * each hour
# like */5 * * * * each 5min
# like 0 0 * * 0 each week
# like 0 0 1 * * each moth
# like 0 0 1 1 * each year

script_git_url="git@github.com:sinlov/Golang-Shell.git"
script_git_local_path="Golang-Shell"
script_git_local_branch="master"
script_git_local_file="SnapShot.sh"
script_local_path="build"

shell_run_path=$(cd `dirname $0`; pwd)

checkFuncBack(){
  if [ $? -eq 0 ]; then
    echo "$1 success"
  else
    echo "[ $1 ] error stop script"
    exit 1
  fi
}

checkEnv(){
    evn_checker=`which $1`
  if [ ! -n "evn_checker" ]; then
    echo "check event [ $1 ] error exit"
    exit 1
  else
    echo -e "Cli [ $1 ] event check success\n-> $1 at Path: ${evn_checker}"
  fi
}

cleanPath(){
  if [ -d "${shell_run_path}/$1/" ]; then
    echo -e "=====\nFind path: ${shell_run_path}/$1/\n=====\n"
    echo -e "try to remove path: ${shell_run_path}/$1/"
    rm -rf "${shell_run_path}/$1"
    checkFuncBack "rm -rf ${shell_run_path}/$1"
    echo -e "\n=====\nFinishremove path: ${shell_run_path}/$1/\n=====\n"
  fi
}

if [ ! -n "$ANDROID_HOME" ]; then
    echo "You are not setting ANDROID_HOME stop build"
    exit 1
else
    echo -e "You are setting ANDROID_HOME\nAt Path: ${ANDROID_HOME}"
fi

checkEnv java
checkEnv android
checkEnv gradle

start_build_time=$(date "+%Y-%m-%d %H:%M:%S")
echo -e "====== just start ${script_git_local_file} ${start_build_time} ======"

cleanPath ${script_git_local_path}
cleanPath ${script_local_path}

git clone ${script_git_url} -b ${script_git_local_branch} ${script_git_local_path}
checkFuncBack "clone ${script_git_url} branch ${script_git_local_branch}"

if [ -d "${shell_run_path}/${script_git_local_path}/" ]; then
  if [ -f "${shell_run_path}/${script_git_local_path}/${script_git_local_file}" ]; then
    chmod +x "${shell_run_path}/${script_git_local_path}/${script_git_local_file}"
    ${shell_run_path}/${script_git_local_path}/${script_git_local_file}
    checkFuncBack "${shell_run_path}/${script_git_local_path}/${script_git_local_file}"
    end_build_time=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "====== End ${script_git_local_file} ${end_build_time} ======"
    time_use=$((`date +%s -d "${end_build_time}"` - `date +%s -d "${start_build_time}"`))
    time_use_format=$(date -d "1970-01-01 CST ${time_use} seconds" "+%T")
    echo -e "total use time ${time_use_format}"
  else
    echo -e "Can not found ${script_git_local_file} at path\n -> ${shell_run_path}/${script_git_local_path}\n stop script!"
    exit 1
  fi
else
  echo -e "clone ${script_git_url}\nFail"
  exit 1
fi
