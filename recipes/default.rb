#
# Cookbook Name:: tomcat_bin
# Recipe:: default
#
# Copyright 2014 Brian Clark
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'java' if node['tomcat_bin']['install_java']

group node['tomcat_bin']['group']

user node['tomcat_bin']['user'] do
  system true
  group node['tomcat_bin']['group']
  system true
  shell '/bin/bash'
end

mirror = node['tomcat_bin']['mirror']
version = node['tomcat_bin']['version']
base_version = version.split('.').first
tomcat_name = "tomcat#{base_version}"
tomcat_home = ::File.join(node['tomcat_bin']['install_dir'], tomcat_name)
server_xml = ::File.join(tomcat_home, 'conf', 'server.xml')
setenv_sh = ::File.join(tomcat_home, 'bin', 'setenv.sh')
logging_properties = ::File.join(tomcat_home, 'conf', 'logging.properties')

ark tomcat_name do
  url "#{mirror}/#{version}/tomcat-#{version}.tar.gz"
  checksum node['tomcat_bin']['checksum']
  version version
  path node['tomcat_bin']['install_dir']
  owner node['tomcat_bin']['user']
  group node['tomcat_bin']['group']
  action :put
end

template "/etc/init.d/#{tomcat_name}" do
  source 'tomcat.init.erb'
  variables(
    tomcat_home: tomcat_home,
    base_version: base_version
  )
  mode 0755
  owner 'root'
  group 'root'
  cookbook node['tomcat_bin']['template_cookbook'] || 'tomcat_bin'
end

template setenv_sh do
  source 'setenv.sh.erb'
  mode 0755
  owner node['tomcat_bin']['user']
  group node['tomcat_bin']['group']
  variables(
    tomcat_home: tomcat_home,
    java_home: node['tomcat_bin']['java_home'],
    catalina_opts: node['tomcat_bin']['catalina_opts'],
    java_opts: node['tomcat_bin']['java_opts']
  )
  cookbook node['tomcat_bin']['template_cookbook'] || 'tomcat_bin'
end

template server_xml do
  source 'server.xml.erb'
  mode 0755
  owner node['tomcat_bin']['user']
  group node['tomcat_bin']['group']
  variables(
    shutdown_port: node['tomcat_bin']['shutdown_port'],
    connectors: node['tomcat_bin']['connectors'],
    executors: node['tomcat_bin']['executors'],
    engine_valves: node['tomcat_bin']['engine_valves'],
    host_valves: node['tomcat_bin']['host_valves'],
    access_log_valve: node['tomcat_bin']['access_log_valve']
  )
  cookbook node['tomcat_bin']['template_cookbook'] || 'tomcat_bin'
end

template logging_properties do
  source 'logging.properties.erb'
  mode 0755
  owner node['tomcat_bin']['user']
  group node['tomcat_bin']['group']
  cookbook node['tomcat_bin']['template_cookbook'] || 'tomcat_bin'
end

service tomcat_name do
  supports restart: true, start: true, stop: true, status: true
  action [:enable, :start]
  subscribes :restart, "template[/etc/init.d/#{tomcat_name}]"
  subscribes :restart, "template[#{server_xml}]"
  subscribes :restart, "template[#{setenv_sh}]"
  subscribes :restart, "template[#{logging_properties}]"
end

logfiles = [
  'catalina.out',
  'catalina.log',
  'manager.log',
  'host-manager.log',
  'localhost.log',
  node['tomcat_bin']['access_log_valve']['prefix'] +
    node['tomcat_bin']['access_log_valve']['suffix']
].map { |logfile| ::File.join(tomcat_home, 'logs', logfile) }

logrotate_app tomcat_name do
  path      logfiles
  options   %w(missingok compress delaycompress copytruncate notifempty)
  frequency node['tomcat_bin']['logrotate_frequency'] || 'weekly'
  rotate    node['tomcat_bin']['logrotate_rotate'] || 4
  create    "0440 #{node['tomcat_bin']['user']} root"
  only_if   node['use_logrotate']
end
