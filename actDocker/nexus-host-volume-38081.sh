#!/bin/bash

echo "need sudo!"

docker_name="nexus"
host_port="38081"
nexus_data="${HOME}/var/nexus-data"

echo -e "this script run nexus evn
name: ${docker_name}
host port: ${host_port}
volume path: ${nexus_data}
"

if [ ! -d "${nexus_data}" ]; then
	echo -e "volume path: ${nexus_data}\nIs not exist just mkdir"
	mkdir -p ${nexus_data}
	chown -R 200 ${nexus_data}
fi

echo -e "just try run neuxs as docker"

docker run -d=true -it -p 0.0.0.0:${host_port}:8081 --name ${docker_name} -v "${nexus_data}:/sonatype-work" sonatype/nexus

echo "run success see at sudo docker ps"
echo -e "You can use
http://127.0.0.1:${host_port}/nexus/
To see!
"

echo "run with -> sudo docker start ${docker_name}"
