#!/bin/sh 

start_docker_service() {
	service_name=$1
	service_docker_version=$2
	service_external_port=$3
	service_internal_port=$4
	service_additional_variables=$5

	# because I see this pattern repeating.
	previous_service=`docker ps -a -f name=$service_name | awk 'NR==2{print $1}'`;
	
	if [ -z "$previous_service" ]
	then
		echo 'pulling '"$service_docker_version"' if not available...'
		docker pull $service_docker_version
		echo 'starting a new docker container for '"$service_name"'...'
		docker run --name $service_name -p $service_external_port:$service_internal_port $service_additional_variables -d $service_docker_version > /dev/null 2>&1
	else
		echo 'restarting previous created docker container for '"$service_name"'...'
		docker stop $service_name > /dev/null 2>&1
		docker start $service_name > /dev/null 2>&1
		set echo on
	fi
	echo "$service_name" 'should be up on 0.0.0.0:'"$service_external_port"', localhost:'"$service_external_port"' or <docker-host-ip>:'"$service_external_port"
}

## find the adminer container named dev-adminer
adminer_version='adminer:latest'
start_docker_service 'dev-adminer' $adminer_version '9000' '8080' ''

## find the mysql container named dev-mysql
mysql_version='mysql:8.0.20'
start_docker_service 'dev-mysql' $mysql_version '3307' '3306' '-e MYSQL_ROOT_PASSWORD=H@r6P@$$w0r6 -e MYSQL_DATABASE=test -e MYSQL_USER=user -e MYSQL_PASSWORD=pass'
