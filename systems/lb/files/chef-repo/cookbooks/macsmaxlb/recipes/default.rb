#
# Cookbook Name:: macsmaxlb
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.


package 'nginx'

service 'nginx' do
  supports :status => true
  action [:enable, :start]
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    :hosts => ['app1', 'app2'],
    :port => '80',
    :application_port => '8484',
    :application_name => 'macsmaxapp',
  )
end
