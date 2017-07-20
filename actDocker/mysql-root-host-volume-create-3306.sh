#!/bin/bash

echo "need sudo!"
sudo pwd

docker_name="mysql-root"
host_port="3306"
mysql_data="${HOME}/var/mysql-root-data"
mysql_root_pwd="root"

echo -e "this script run mysql-root evn
name: ${docker_name}
host port: ${host_port}
volume path: ${mysql_data}
"

if [ ! -d "${mysql_data}" ]; then
	echo -e "volume path : ${mysql_data}\nIs not exist just mkdir"
	mkdir -p ${mysql_data}
	chown -R 200 ${mysql_data}
	chmod -R 466 ${mysql_data}
fi

echo -e "just try run mysql-root as docker"

docker create -d -e MYSQL_ROOT_PASSWORD=${mysql_root_pwd} --name ${docker_name} -v ${mysql_data}/data:/var/lib/mysql -p ${host_port}:3306 mysql
#docker run -d -e MYSQL_ROOT_PASSWORD=${mysql_root_pwd} --name ${docker_name} -v ${mysql_data}/my.cnf:/etc/mysql/my.cnf -v ${mysql_data}/data:/var/lib/mysql -p ${host_port}:3306 mysql

echo "create success see at sudo docker ps -a"
echo "run with sudo docker start ${docker_name}"
