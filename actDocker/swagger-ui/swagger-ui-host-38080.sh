#!/bin/bash

echo "need sudo!"
now_path="`sudo pwd`"
echo -e "now path ${now_path}"

run_path=$(pwd)
shell_run_name=$(basename $0)
shell_run_path=$(cd `dirname $0`; pwd)

# local_host="`hostname`"
# local_ip=`host $local_host 2>/dev/null | awk '{print $NF}'`

docker_name="swagger-ui"
host_domain="127.0.0.1"
host_port="38080"
access_protocol="http://"
access_route="/"

swagger_ui_data="${run_path}/data/swagger-ui"
api_url="http://generator.swagger.io/api/swagger.json"

checkFuncBack(){
  if [ $? -ne 0 ]; then
    echo -e "\033[;31mRun [ $1 ] error exit code 1\033[0m"
    exit 1
  # else
  #   echo -e "\033[;30mRun [ $1 ] success\033[0m"
fi
}

checkEnv(){
  evn_checker=`which $1`
  checkFuncBack "which $1"
  if [ ! -n "evn_checker" ]; then
    echo -e "\033[;31mCheck event [ $1 ] error exit\033[0m"
    exit 1
  # else
  #   echo -e "\033[;32mCli [ $1 ] event check success\033[0m\n-> \033[;34m$1 at Path: ${evn_checker}\033[0m"
fi
}

echo -e "This script create docker swagger-ui
Evn
name: ${docker_name}
host port: ${host_port}
host domain: ${host_domain}
volume path: ${swagger-ui_data}
api_url=${api_url}
"

checkEnv docker

#if [ ! -d "${swagger_ui_data}" ]; then
  #echo -e "volume path : ${swagger-ui_data}\nIs not exist just mkdir"
  #mkdir -p ${swagger_ui_data}
  #chown -R 200 ${swagger_ui_data}
  #chmod -R 466 ${swagger_ui_data}
#fi

old_container=$(docker ps --filter 'name=${docker_name}' | wc -l)
echo -e "old_container ${old_container}"

if [[ "${olo_container}" > "1" ]]; then
    echo -e "find out same name [ ${docker_name} ] container just rm it"
    echo -e "docker stop ${docker_name}"
    docker stop ${docker_name}
    checkFuncBack "docker stop ${docker_name}"
    echo -e "docker rm ${docker_name}"
    docker rm ${docker_name}
    checkFuncBack "docker rm ${docker_name}"
fi

echo -e "Just try run swagger-ui as docker"

echo -e "docker create -it --name ${docker_name} -e API_URL=${api_url} -p ${host_port}:8080 swaggerapi/swagger-ui"
docker create -it --name ${docker_name} -e API_URL=${api_url} -p ${host_port}:8080 swaggerapi/swagger-ui
echo -e "create success see at => docker ps -a"
echo -e "you must run container => docker start ${docker_name}"
echo -e "access on ${access_protocol}${host_domain}:${host_port}${access_route}"
