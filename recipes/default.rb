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

include_recipe 'logrotate'

apache_tomcat node['apache_tomcat']['home'] do
  user node['apache_tomcat']['user']
  group node['apache_tomcat']['group']
  service_name node['apache_tomcat']['service_name']
  enable_service node['apache_tomcat']['enable_service']
  version node['apache_tomcat']['version']
  mirror node['apache_tomcat']['mirror']
  checksum node['apache_tomcat']['checksum']
  kill_delay node['apache_tomcat']['kill_delay']
  java_home node['apache_tomcat']['java_home']
  initial_heap_size node['apache_tomcat']['initial_heap_size']
  max_heap_size node['apache_tomcat']['max_heap_size']
  max_perm_size node['apache_tomcat']['max_perm_size']
  catalina_opts node['apache_tomcat']['catalina_opts']
  java_opts node['apache_tomcat']['java_opts']
  jmx_port node['apache_tomcat']['jmx_port']
  jmx_authenticate node['apache_tomcat']['jmx_authenticate']
  jmx_monitor_password node['apache_tomcat']['jmx_monitor_password']
  jmx_control_password node['apache_tomcat']['jmx_control_password']
  shutdown_port node['apache_tomcat']['shutdown_port']
  pool_enabled node['apache_tomcat']['pool_enabled']
  pool_additional node['apache_tomcat']['pool_additional']
  http_port node['apache_tomcat']['http_port']
  http_additional node['apache_tomcat']['http_additional']
  ssl_port node['apache_tomcat']['ssl_port']
  ssl_additional node['apache_tomcat']['ssl_additional']
  ajp_port node['apache_tomcat']['ajp_port']
  ajp_additional node['apache_tomcat']['ajp_additional']
  engine_valves node['apache_tomcat']['engine_valves']
  host_valves node['apache_tomcat']['host_valves']
  access_log_enabled node['apache_tomcat']['access_log_enabled']
  access_log_additional node['apache_tomcat']['access_log_additional']
  tomcat_users node['apache_tomcat']['tomcat_users']
  log_dir node['apache_tomcat']['log_dir']
  logrotate_count node['apache_tomcat']['logrotate_count']
  logrotate_frequency node['apache_tomcat']['logrotate_frequency']
  setenv_template node['apache_tomcat']['setenv_template']
  server_xml_template node['apache_tomcat']['server_xml_template']
  logging_properties_template node['apache_tomcat']['logging_properties_template']
  logrotate_template node['apache_tomcat']['logrotate_template']
  tomcat_users_template node['apache_tomcat']['tomcat_users_template']
end
