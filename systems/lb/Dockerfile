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

RUN cd /etc/chef-repo && chef-client --local-mode --runlist 'recipe[macsmaxlb]'

# add logs volumes etc

WORKDIR ["/etc/nginx"]
CMD ["/usr/sbin/nginx"]
EXPOSE 80
