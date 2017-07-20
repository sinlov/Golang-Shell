#!/bin/bash

echo "need sudo!"
sudo pwd

docker_name="gogs"
host_port="30080"
host_ssh_port="30022"
mysql_docker_name="mysql-gogs"
gogs_data="${HOME}/var/gogs"

echo -e "this script run gogs evn
name: ${docker_name}
host port: ${host_port}
host ssh port: ${host_ssh_port}
mysql docker name: ${mysql_docker_name}
volume path: ${gogs_data}
"

if [ ! -d "${gogs_data}" ]; then
	echo -e "volume path : ${gogs_data}\nIs not exist just mkdir"
	mkdir -p ${gogs_data}
	chown -R 200 ${gogs_data}
	chmod -R 466 ${gogs_data}
else
    echo -e "Find older gogs dir: ${gogs_data}\nJust use older."
fi

echo -e "just try create gogs as docker"

docker create -it --name ${docker_name} -p ${host_ssh_port}:22 -p ${host_port}:3000 -v ${gogs_data}:/data --link ${mysql_docker_name}:mysql gogs/gogs

echo "create [ ${docker_name} ] success see at sudo docker ps -a"

echo -e "If want config
- connect db use ${mysql_docker_name}:port
- http port use inner port [ 3000 ] not ${host_port}
- ssh port use outer port [ ${host_ssh_port} ]
- do not use inner ssh mode!
"

echo "run with -> sudo docker start ${docker_name}"
