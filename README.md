# Test Repository
This repository contains a test aimed at demonstrate the interaction between Chef and Docker

## Background information
The scripts and tools used in this repository will deploy three docker containers running Ubuntu Trusty with two "Hello World" go applications balanced by an Nginx container.
Docker is used to start the containers, whereas Chef takes care of installing and configuring the packages (Nginx, Golang). 
The Load Balancer is able to communicate to the app docker containers internally using the linking system [Dockerlinks](http://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/).


* Once the containers are running, a single port will be exposed (8080). Curling that port will show the output from the two go apps containers.
* If the app is modified in git, running *./deploy.sh upgrade* will update the app containers. (Disclaimer: No care was taken to prevent downtime while re-deploying)

Example:
```
Hi there, I'm served from 78aa671485e8!
X-Forwarded-For: 192.168.99.1
Hi there, I'm served from fdda44356bc1!
X-Forwarded-For: 192.168.99.1
```

## Prerequisites
* Have a working Docker environment. This environment was tested on a Mac OSX running docker-machine. Please refer to Docker toolbox setup here: https://www.docker.com/docker-toolbox
* Have curl instlled to test the environment

## Usage

The *deploy.sh* script will take care of deploying, upgrading and removing the docker containers.

Usage:
```
$ ./deploy.sh
Usage: ./deploy.sh {deploy|upgrade|cleanup|status}
```

Example:
```
$ ./deploy.sh status
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

$ ./deploy.sh deploy
Building container image for app
Sending build context to Docker daemon 53.76 kB
[... suppressed docker build output ...]
Successfully built b1a86ac45a74
28c5a6ae2a57cb4eaa34ef32b3a7d050940fb03026881a4386a812cb08ad4909
736ef3f5ac5fd72ffd86b3bf2f5b68093336f5f1ee76ad57d0f7854439b2cd1f

Building container image for lb
[... suppressed docker build output ...]
Sending build context to Docker daemon  55.3 kB
470310f9add3137ae04a0311504bab28fa3cc4248e3c4f3672d1d724aefec138


docker-machine found, assuming not a native docker setup

Testing that the application was deployed at 192.168.99.100:8080 attempting test

Hi there, I'm served from 28c5a6ae2a57!
X-Forwarded-For: 192.168.99.1
Hi there, I'm served from 736ef3f5ac5f!
X-Forwarded-For: 192.168.99.1

$ ./deploy.sh status
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                  NAMES
470310f9add3        lb                  "/usr/sbin/nginx"      23 seconds ago      Up 20 seconds       0.0.0.0:8080->80/tcp   lb
736ef3f5ac5f        app                 "/usr/local/bin/app"   30 seconds ago      Up 27 seconds       8484/tcp               app2
28c5a6ae2a57        app                 "/usr/local/bin/app"   30 seconds ago      Up 27 seconds       8484/tcp               app1

$ ./deploy.sh upgrade
app1
 |_ container stopped
app2
 |_ container stopped
app1
 |_ container removed
app2
 |_ container removed
Building container image for app
Sending build context to Docker daemon 53.76 kB
[... suppressed docker build output ...]
4c9e165c9feff540604bf1887581d0034683082e82251d43ab0f9141aefc175f
6acffe471b41852b68f1c4b09dbb1c5e742bed35f6f1e52a1a918dccd60fb75d

$ ./deploy.sh status
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                  NAMES
6acffe471b41        app                 "/usr/local/bin/app"   5 seconds ago       Up 2 seconds        8484/tcp               app2
4c9e165c9fef        app                 "/usr/local/bin/app"   5 seconds ago       Up 2 seconds        8484/tcp               app1
470310f9add3        lb                  "/usr/sbin/nginx"      50 seconds ago      Up 47 seconds       0.0.0.0:8080->80/tcp   lb

$ curl http://192.168.99.100:8080
Hi there, I'm served from 4c9e165c9fef!
X-Forwarded-For: 192.168.99.1

$ curl http://192.168.99.100:8080
Hi there, I'm served from 6acffe471b41!
X-Forwarded-For: 192.168.99.1

$ ./deploy.sh cleanup
app1
 |_ container stopped
app2
 |_ container stopped
app1
 |_ container removed
app2
 |_ container removed
lb
 |_ container stopped
lb
 |_ container removed
```
