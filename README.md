### graylog-docker

Scripts to easily deploy Graylog using Docker using the official Graylog, Elasticsearch and Mongodb Docker images.


## Prerequisites: 

1. Docker is installed and configured
2. A \*nix machine (this is a BASH script)


## Installation:


### Download the repository:

`git clone https://github.com/heywoodlh/graylog-docker`

`cd graylog-docker`


### Configure Graylog:

1. Edit `./graylog/config/graylog.conf`:

* Change `password_secret` to equal the output of the command `pwgen -N 1 -s 96`
* Change `root_password_sha2` to equal the output of the command `echo -n yourpassword | shasum -a 256` (change `yourpassword` to equal the value of the admin password you'd like)
* (Optional) Change `root_username = admin` to a different admin username you'd prefer

2. Edit `./graylog-docker.sh`:

* Set the array GRAYLOG_PORTS to equal all the ports you'd like Graylog to expose, separated by spaces and in quotes:
	`declare -a GRAYLOG_PORTS=("9000" "12201" "514/udp")`


### Run the script:

`./graylog-docker.sh`



## Access Graylog:

Navigate to http://localhost:9000 (replace localhost with a remote hostname/IP address if deployed remotely)



## Updating Graylog's opened ports or any other configuration:

TL;DR: run `./graylog-docker.sh` after file changes are made in the repository.

If you add an input on a port and would like that port to be exposed, add it to the GRAYLOG_PORTS array in `./graylog-docker.sh` then run `./graylog-docker.sh` again.

If you do any other configuration change to the files in the repository, just run `./graylog-docker.sh` to update the config.


## Upgrading Graylog and the other containers:

Set up a cronjob to run `./graylog-docker.sh` at a specific time. 

The script will pull updated images, remove the containers and create new instances. 

*Each of the containers are using volumes which will persist between instances getting upgraded -- don't worry about the containers being removed by the script.* 
