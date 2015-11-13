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

## Usage

The *deploy.sh* script will take care of deploying, upgrading and removing the docker containers.

Usage:
```
ngardini@macsmac: /data01/scratch/git/github_macsmax/test ]$ ./deploy.sh
Usage: ./deploy.sh {deploy|upgrade|cleanup|status}
```

Example:
```
[ mmongardini@macsmac: /data01/scratch/git/github_macsmax/test ]$ ./deploy.sh status
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

[ mmongardini@macsmac: /data01/scratch/git/github_macsmax/test ]$ ./deploy.sh deploy
Building container image for app
Sending build context to Docker daemon 53.76 kB
Step 1 : FROM ubuntu:trusty
 ---> e9ae3c220b23
Step 2 : MAINTAINER Max Mongardini<massimo@mongardini.it>
 ---> Using cache
 ---> 855c4ea06c1a
Step 3 : ENV DEBIAN_FRONTEND noninteractive
 ---> Using cache
 ---> 24c18f151076
Step 4 : RUN apt-get update &&   apt-get -y install curl
 ---> Using cache
 ---> 33b6873116b7
Step 5 : RUN curl -L https://www.opscode.com/chef/install.sh | bash
 ---> Using cache
 ---> bf8b25af70bd
Step 6 : ADD files/chef-repo /etc/chef-repo
 ---> Using cache
 ---> 4cf09725fbe5
Step 7 : RUN cd /etc/chef-repo/cookbooks && knife cookbook site download golang && tar zxvf golang*.tar.gz
 ---> Using cache
 ---> 9297944ec122
Step 8 : RUN cd /etc/chef-repo && chef-client --local-mode --runlist 'recipe[macsmaxapp],recipe[golang]'
 ---> Using cache
 ---> 5adb84bba81d
Step 9 : RUN mkdir /usr/src/app
 ---> Using cache
 ---> 730c03914ddf
Step 10 : ADD files/app.go /usr/src/app/app.go
 ---> Using cache
 ---> 87a239dd43fd
Step 11 : RUN cd /usr/src/app && /usr/local/go/bin/go build app.go ; mv app /usr/local/bin/app
 ---> Using cache
 ---> da09424ed011
Step 12 : EXPOSE 8484
 ---> Using cache
 ---> b8747e79e22e
Step 13 : CMD /usr/local/bin/app
 ---> Using cache
 ---> b1a86ac45a74
Successfully built b1a86ac45a74
/data01/scratch/git/github_macsmax/test
28c5a6ae2a57cb4eaa34ef32b3a7d050940fb03026881a4386a812cb08ad4909
736ef3f5ac5fd72ffd86b3bf2f5b68093336f5f1ee76ad57d0f7854439b2cd1f
Already up-to-date.
Building container image for lb
Sending build context to Docker daemon  55.3 kB
Step 1 : FROM ubuntu:trusty
 ---> e9ae3c220b23
Step 2 : MAINTAINER Max Mongardini<massimo@mongardini.it>
 ---> Using cache
 ---> 855c4ea06c1a
Step 3 : ENV DEBIAN_FRONTEND noninteractive
 ---> Using cache
 ---> 24c18f151076
Step 4 : RUN apt-get update &&   apt-get -y install curl
 ---> Using cache
 ---> 33b6873116b7
Step 5 : RUN curl -L https://www.opscode.com/chef/install.sh | bash
 ---> Using cache
 ---> bf8b25af70bd
Step 6 : ADD files/chef-repo /etc/chef-repo
 ---> Using cache
 ---> 08808a45fb95
Step 7 : RUN cd /etc/chef-repo && chef-client --local-mode --runlist 'recipe[macsmaxlb]'
 ---> Using cache
 ---> cbb1be54e780
Step 8 : WORKDIR ["/etc/nginx"]
 ---> Using cache
 ---> a3b67ac11ec6
Step 9 : CMD /usr/sbin/nginx
 ---> Using cache
 ---> 18cebbd01183
Step 10 : EXPOSE 80
 ---> Using cache
 ---> 36556c160fba
Successfully built 36556c160fba
/data01/scratch/git/github_macsmax/test
470310f9add3137ae04a0311504bab28fa3cc4248e3c4f3672d1d724aefec138


docker-machine found, assuming not a native docker setup

Testing that the application was deployed at 192.168.99.100:8080 attempting test

Hi there, I'm served from 28c5a6ae2a57!
X-Forwarded-For: 192.168.99.1
Hi there, I'm served from 736ef3f5ac5f!
X-Forwarded-For: 192.168.99.1

[ mmongardini@macsmac: /data01/scratch/git/github_macsmax/test ]$ ./deploy.sh status
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                  NAMES
470310f9add3        lb                  "/usr/sbin/nginx"      23 seconds ago      Up 20 seconds       0.0.0.0:8080->80/tcp   lb
736ef3f5ac5f        app                 "/usr/local/bin/app"   30 seconds ago      Up 27 seconds       8484/tcp               app2
28c5a6ae2a57        app                 "/usr/local/bin/app"   30 seconds ago      Up 27 seconds       8484/tcp               app1

[ mmongardini@macsmac: /data01/scratch/git/github_macsmax/test ]$ ./deploy.sh upgrade
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
Step 1 : FROM ubuntu:trusty
 ---> e9ae3c220b23
Step 2 : MAINTAINER Max Mongardini<massimo@mongardini.it>
 ---> Using cache
 ---> 855c4ea06c1a
Step 3 : ENV DEBIAN_FRONTEND noninteractive
 ---> Using cache
 ---> 24c18f151076
Step 4 : RUN apt-get update &&   apt-get -y install curl
 ---> Using cache
 ---> 33b6873116b7
Step 5 : RUN curl -L https://www.opscode.com/chef/install.sh | bash
 ---> Using cache
 ---> bf8b25af70bd
Step 6 : ADD files/chef-repo /etc/chef-repo
 ---> Using cache
 ---> 4cf09725fbe5
Step 7 : RUN cd /etc/chef-repo/cookbooks && knife cookbook site download golang && tar zxvf golang*.tar.gz
 ---> Using cache
 ---> 9297944ec122
Step 8 : RUN cd /etc/chef-repo && chef-client --local-mode --runlist 'recipe[macsmaxapp],recipe[golang]'
 ---> Using cache
 ---> 5adb84bba81d
Step 9 : RUN mkdir /usr/src/app
 ---> Using cache
 ---> 730c03914ddf
Step 10 : ADD files/app.go /usr/src/app/app.go
 ---> Using cache
 ---> 87a239dd43fd
Step 11 : RUN cd /usr/src/app && /usr/local/go/bin/go build app.go ; mv app /usr/local/bin/app
 ---> Using cache
 ---> da09424ed011
Step 12 : EXPOSE 8484
 ---> Using cache
 ---> b8747e79e22e
Step 13 : CMD /usr/local/bin/app
 ---> Using cache
 ---> b1a86ac45a74
Successfully built b1a86ac45a74
/data01/scratch/git/github_macsmax/test
4c9e165c9feff540604bf1887581d0034683082e82251d43ab0f9141aefc175f
6acffe471b41852b68f1c4b09dbb1c5e742bed35f6f1e52a1a918dccd60fb75d

[ mmongardini@macsmac: /data01/scratch/git/github_macsmax/test ]$ ./deploy.sh status
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                  NAMES
6acffe471b41        app                 "/usr/local/bin/app"   5 seconds ago       Up 2 seconds        8484/tcp               app2
4c9e165c9fef        app                 "/usr/local/bin/app"   5 seconds ago       Up 2 seconds        8484/tcp               app1
470310f9add3        lb                  "/usr/sbin/nginx"      50 seconds ago      Up 47 seconds       0.0.0.0:8080->80/tcp   lb

[ mmongardini@macsmac: /data01/scratch/git/github_macsmax/test ]$ curl http://192.168.99.100:8080
Hi there, I'm served from 4c9e165c9fef!
X-Forwarded-For: 192.168.99.1

[ mmongardini@macsmac: /data01/scratch/git/github_macsmax/test ]$ curl http://192.168.99.100:8080
Hi there, I'm served from 6acffe471b41!
X-Forwarded-For: 192.168.99.1

[ mmongardini@macsmac: /data01/scratch/git/github_macsmax/test ]$ ./deploy.sh cleanup
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
