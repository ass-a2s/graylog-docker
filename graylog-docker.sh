#!/usr/bin/env bash
#Change these variables if you'd like

## Set this array to have all the ports you want Graylog to expose as inputs separated by spaces and in double quotes
declare -a GRAYLOG_INPUT_PORTS=("12201" "514/udp")


BASE_DIR="$(pwd)"
ELASTICSEARCH_DIR="$BASE_DIR/elasticsearch"
GRAYLOG_DIR="$BASE_DIR/graylog"


## This parses all the ports in GRAYLOG_INPUT_PORTS into a format Docker will use
CATTED_INPUT_PORTS=''
for PORT in "${GRAYLOG_INPUT_PORTS[@]}"
do
	if echo "$PORT" | grep "/udp"
	then
		SUFFIX="/udp"
		HOST_PORT=${PORT%"$SUFFIX"}
	else
		HOST_PORT="$PORT"
	fi
	CATTED_INPUT_PORTS+="-p $HOST_PORT:$PORT "
done


### Mongo build

docker pull mongo

if docker ps | grep 'mongo'
then
	docker stop mongo
	docker rm mongo
fi		

docker run --name mongo -d mongo:3



### Elasticsearch build

docker pull docker.elastic.co/elasticsearch/elasticsearch:5.6.12

if docker ps | grep 'elasticsearch'
then
	docker stop elasticsearch
	docker rm elasticsearch
fi

docker run --name elasticsearch -v "$ELASTICSEARCH_DIR"/data:/usr/share/elasticsearch/data -v "$ELASTICSEARCH_DIR"/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml -e "http.host=0.0.0.0" -e "xpack.security.enabled=false" -d docker.elastic.co/elasticsearch/elasticsearch:5.6.12



### Graylog Build

if docker ps | grep 'graylog'
then
	docker stop graylog
	docker rm graylog
fi

docker run --name graylog --link mongo --link elasticsearch -p 9000:9000 "$CATTED_PORTS" -e GRAYLOG_WEB_ENDPOINT_URI="http://127.0.0.1:9000/api" -v "$GRAYLOG_DIR/config/":/usr/share/graylog/data/config -v "$GRAYLOG_DIR"/journal/:/usr/share/graylog/data/journal  -d graylog/graylog:2.4 
