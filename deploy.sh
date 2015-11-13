#!/bin/bash

#Number of Apps
NAPPS=2

#external port mapped to the nginx lb
PORT=8080

if [ ! -x `which docker` ]; then
	echo "Error, unable to find the docker binary, please install the docker toolbox. https://www.docker.com/docker-toolbox"
fi 

function deployapp {

	#pull the repo
	git pull
	
	#Build the docker containers images
	for i in app ; do
		cd systems/$i
		echo "Building container image for $i"
		sleep 1
		docker build -t $i ./
		cd -
	done
	
	#Run the apps containers first
	for a in `seq 1 $NAPPS` ; do 
		docker run -d --name app${a} app
	done
}

function deploylb {

	#pull the repo
	git pull

	#Run the nginx lb
	cd systems/lb
	echo "Building container image for lb"
	sleep 1
	docker build -t lb ./
	cd -
	docker run -d -p ${PORT}:80 --link app1 --link app2 --name lb lb
}

function test {	
	#Test
	if [ -x `which docker-machine` ]; then
		echo -e "\n\ndocker-machine found, assuming not a native docker setup"
		machine=`docker-machine ls | tail -n 1 | awk '{print $1}'`
		ip=`docker-machine ip $machine`
		echo -e "\nTesting that the application was deployed at ${ip}:${PORT} attempting test\n"
		for a in `seq 1 $NAPPS` ; do
			curl -s http://${ip}:${PORT}
		done
	else
		echo -e "\n\nPlease test that the two test application servers are called in a round-robin fashion.\n"
	fi
	exit 0
}

function status {
	docker ps
}

function stopapp {
	for a in `seq 1 $NAPPS` ; do
                docker stop app${a} && echo " |_ container stopped"
        done
}

function stoplb {
	docker stop lb && echo " |_ container stopped"
}

function removeapp {
	for a in `seq 1 $NAPPS` ; do
                docker rm app${a} && echo " |_ container removed"
        done
}

function removelb {
	docker rm lb && echo " |_ container removed"
}

case "$1" in
        deploy)
            deployapp
	    deploylb
	    test
            ;;
         
        upgrade)
	    stopapp
	    removeapp
            deployapp
            ;;
        cleanup)
	    stopapp
	    removeapp
	    stoplb
	    removelb
	    ;;
        status)
            status
            ;;
         
        *)
	    echo $"Usage: $0 {deploy|upgrade|cleanup|status}"
	    exit 1
esac
