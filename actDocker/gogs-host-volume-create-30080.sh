#!/bin/bash

echo "need sudo!"
sudo pwd

docker_name="gogs"
host_port="30080"
host_ssh_port="30022"
mysql_docker_name="mysql-gogs"
mysql_docker_alias="mysql57"
mysql_docker_net="nginxdevops_default"
gogs_data="${HOME}/var/gogs"

echo -e "this script run gogs evn
name: ${docker_name}
host port: ${host_port}
host ssh port: ${host_ssh_port}
mysql docker name: ${mysql_docker_name}
mysql docker alias: ${mysql_docker_alias}
mysql docker net: ${mysql_docker_net}
volume path: ${gogs_data}

mysql_docker_net ${mysql_docker_net} use
-> sudo docker network ls
to see
"

if [ ! -d "${gogs_data}" ]; then
	echo -e "volume path : ${gogs_data}\nIs not exist just mkdir"
	mkdir -p ${gogs_data}
	chown -R 200 ${gogs_data}
	chmod -R 466 ${gogs_data}
else
    echo -e "Find older gogs dir: ${gogs_data}\nJust use older."
fi

echo -e "\nJust try create gogs as docker"

echo -e "docker create -it --name ${docker_name} -p ${host_ssh_port}:22 -p ${host_port}:3000 -v ${gogs_data}:/data --link ${mysql_docker_name}:${mysql_docker_alias} --net ${mysql_docker_net} gogs/gogs"

docker create -it --name ${docker_name} -p ${host_ssh_port}:22 -p ${host_port}:3000 -v ${gogs_data}:/data --link ${mysql_docker_name}:${mysql_docker_alias} --net ${mysql_docker_net} gogs/gogs

echo -e "create [ ${docker_name} ] success see at -> sudo docker ps -a\n"

echo -e "If want config
- connect db use ${mysql_docker_name}:port
- http port use inner port [ 3000 ] not ${host_port}
- ssh port use outer port [ ${host_ssh_port} ]
- do not use inner ssh mode!
"

echo "run with -> sudo docker start ${docker_name}"
