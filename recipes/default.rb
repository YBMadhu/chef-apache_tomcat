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
include_recipe 'logrotate' if node['tomcat_bin']['logrotate']['enabled']

group node['tomcat_bin']['group']

user node['tomcat_bin']['user'] do
  system true
  group node['tomcat_bin']['group']
  shell '/bin/bash'
end

version = node['tomcat_bin']['version']
install_dir = ::File.dirname(node['tomcat_bin']['home'])
name = ::File.basename(node['tomcat_bin']['home'])

ark name do
  url "#{node['tomcat_bin']['mirror']}/#{version}/tomcat-#{version}.tar.gz"
  checksum node['tomcat_bin']['checksum']
  version version
  path install_dir
  owner node['tomcat_bin']['user']
  group node['tomcat_bin']['group']
  action :put
  notifies :configure, "tomcat_bin[#{name}]", :immediately
end

tomcat_bin name do
  home node['tomcat_bin']['home']
  action [:configure]
end
