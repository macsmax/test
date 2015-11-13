# VERSION               0.0.1

FROM ubuntu:trusty
MAINTAINER Max Mongardini<massimo@mongardini.it>

# Basics
# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install curl

# Install chef
RUN curl -L https://www.opscode.com/chef/install.sh | bash

# add git clone of app and lb
ADD files/chef-repo /etc/chef-repo
RUN cd /etc/chef-repo/cookbooks && knife cookbook site download golang && tar zxvf golang*.tar.gz
RUN cd /etc/chef-repo && chef-client --local-mode --runlist 'recipe[macsmaxapp],recipe[golang]'

RUN mkdir /usr/src/app 
ADD files/app.go /usr/src/app/app.go 
RUN cd /usr/src/app && /usr/local/go/bin/go build app.go ; mv app /usr/local/bin/app


# add logs volumes etc
EXPOSE 8484
CMD ["/usr/local/bin/app"]
