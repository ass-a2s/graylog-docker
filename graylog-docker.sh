#!/usr/bin/env bash
#Change these variables if you'd like

## Set this array to have all the ports you want Graylog to expose as inputs separated by spaces and in double quotes
declare -a GRAYLOG_PORTS=("9000" "12201" "514/udp")


BASE_DIR="$(pwd)"
ELASTICSEARCH_DIR="$BASE_DIR/elasticsearch"
GRAYLOG_DIR="$BASE_DIR/graylog"


## This parses all the ports in GRAYLOG_PORTS into a format Docker will use
CATTED_PORTS=''
for PORT in "${GRAYLOG_PORTS[@]}"
do
	if echo "$PORT" | grep --quiet "/udp"
	then
		SUFFIX="/udp"
		HOST_PORT=${PORT%"$SUFFIX"}
	else
		HOST_PORT="$PORT"
	fi
	CATTED_PORTS+="-p $HOST_PORT:$PORT "
done


### Mongo build

docker pull mongo

if docker ps --all | grep --quiet 'mongo'
then
	docker stop mongo
	docker rm mongo
fi		

 
docker volume ls | grep --quiet 'mongo_data'
VOLUME_STAT="$?"

if [[ "$VOLUME_STAT" != 0 ]]
then
	docker volume create mongo_data --driver local
fi


docker run --name mongo -v mongo_data:/data/db -d mongo:3



### Elasticsearch build

docker pull docker.elastic.co/elasticsearch/elasticsearch:5.6.12

if docker ps --all | grep --quiet 'elasticsearch'
then
	docker stop elasticsearch
	docker rm elasticsearch
fi

docker volume ls | grep --quiet 'es_data'
VOLUME_STAT="$?"
if [[ "$VOLUME_STAT" != 0 ]]
then
	docker volume create es_data --driver local
fi

docker run --name elasticsearch -v "$ELASTICSEARCH_DIR"/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v es_data:/usr/share/elasticsearch/data -e "http.host=0.0.0.0" -e "xpack.security.enabled=false" -d docker.elastic.co/elasticsearch/elasticsearch:5.6.12



### Graylog Build

if docker ps --all | grep --quiet 'graylog'
then
	docker stop graylog
	docker rm graylog
fi

docker volume ls | grep --quiet 'graylog_journal'
VOLUME_STAT="$?"
if [[ "$VOLUME_STAT" != 0 ]]
then
	docker volume create graylog_journal --driver local
fi


docker run --name graylog --link mongo --link elasticsearch" $CATTED_PORTS" -e GRAYLOG_WEB_ENDPOINT_URI="http://127.0.0.1:9000/api" -v "$GRAYLOG_DIR/config/":/usr/share/graylog/data/config -v graylog_journal:/usr/share/graylog/data/journal  -d graylog/graylog:2.4 
