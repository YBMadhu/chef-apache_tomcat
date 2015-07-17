#
# Cookbook Name:: apache_tomcat
# Recipe:: default
#
# Copyright 2014 Brian Clark
#
# Licensed under the Apache License Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing software
# distributed under the License is distributed on an "AS IS" BASIS
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

apache_tomcat node['apache_tomcat']['home'] do
  mirror node['apache_tomcat']['mirror']
  version node['apache_tomcat']['version']
  checksum node['apache_tomcat']['checksum']
end

group node['apache_tomcat']['group'] do
  system true
  only_if { node['apache_tomcat']['create_service_user'] }
end

user node['apache_tomcat']['user'] do
  comment 'Tomcat Service User'
  system true
  group node['apache_tomcat']['group']
  shell '/bin/false'
  only_if { node['apache_tomcat']['create_service_user'] }
end

apache_tomcat_instance 'base' do
  base  node['apache_tomcat']['base']
  jmx_port node['apache_tomcat']['jmx_port']
  shutdown_port node['apache_tomcat']['shutdown_port']
  http_port node['apache_tomcat']['http_port']
  ssl_port node['apache_tomcat']['ssl_port']
  ajp_port node['apache_tomcat']['ajp_port']
  only_if { node['apache_tomcat']['run_base_instance'] }
end

node['apache_tomcat']['instances'].each do |name, attribs|
  apache_tomcat_instance name do
    attribs.each { |k, v| send(k, v) if v }
  end
end
