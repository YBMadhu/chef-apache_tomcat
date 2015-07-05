#
# Cookbook Name:: tomcat_bin
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

tomcat_bin node['tomcat_bin']['home'] do
  user node['tomcat_bin']['user']
  group node['tomcat_bin']['group']
  service_name node['tomcat_bin']['service_name']
  enable_service node['tomcat_bin']['enable_service']
  version node['tomcat_bin']['version']
  mirror node['tomcat_bin']['mirror']
  checksum node['tomcat_bin']['checksum']
  kill_delay node['tomcat_bin']['kill_delay']
  java_home node['tomcat_bin']['java_home']
  initial_heap_size node['tomcat_bin']['initial_heap_size']
  max_heap_size node['tomcat_bin']['max_heap_size']
  max_perm_size node['tomcat_bin']['max_perm_size']
  catalina_opts node['tomcat_bin']['catalina_opts']
  java_opts node['tomcat_bin']['java_opts']
  jmx_port node['tomcat_bin']['jmx_port']
  jmx_authenticate node['tomcat_bin']['jmx_authenticate']
  jmx_monitor_password node['tomcat_bin']['jmx_monitor_password']
  jmx_control_password node['tomcat_bin']['jmx_control_password']
  shutdown_port node['tomcat_bin']['shutdown_port']
  pool_enabled node['tomcat_bin']['pool_enabled']
  pool_additional node['tomcat_bin']['pool_additional']
  http_port node['tomcat_bin']['http_port']
  http_additional node['tomcat_bin']['http_additional']
  ssl_port node['tomcat_bin']['ssl_port']
  ssl_additional node['tomcat_bin']['ssl_additional']
  ajp_port node['tomcat_bin']['ajp_port']
  ajp_additional node['tomcat_bin']['ajp_additional']
  engine_valves node['tomcat_bin']['engine_valves']
  host_valves node['tomcat_bin']['host_valves']
  access_log_enabled node['tomcat_bin']['access_log_enabled']
  access_log_additional node['tomcat_bin']['access_log_additional']
  log_dir node['tomcat_bin']['log_dir']
  logrotate_count node['tomcat_bin']['logrotate_count']
  logrotate_frequency node['tomcat_bin']['logrotate_frequency']
end
