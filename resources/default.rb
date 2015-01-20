#
# Cookbook Name:: tomcat_bin
# Resource:: default
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
#
# rubocop:disable Metrics/LineLength

actions :install, :configure, :restart
default_action :configure

attribute :home, kind_of: String, name_attribute: true, required: true
attribute :service_name, kind_of: String
attribute :user, kind_of: String, default: node['tomcat_bin']['user']
attribute :group, kind_of: String, default: node['tomcat_bin']['group']
attribute :kill_delay, regex: /^[1-9][0-9]?$/, default: node['tomcat_bin']['kill_delay']

attribute :version, kind_of: String, default: node['tomcat_bin']['version']
attribute :mirror, kind_of: String, default: node['tomcat_bin']['mirror']
attribute :checksum, kind_of: String, default: node['tomcat_bin']['checksum']

attribute :java_home, kind_of: String
attribute :catalina_opts, kind_of: [String, Array]
attribute :java_opts, kind_of: [String, Array]
attribute :setenv_opts, kind_of: Array, default: []

attribute :shutdown_port, kind_of: Integer, default: node['tomcat_bin']['shutdown_port']
attribute :thread_pool, kind_of: Hash, default: node['tomcat_bin']['thread_pool']
attribute :http, kind_of: Hash, default: node['tomcat_bin']['http']
attribute :ssl, kind_of: Hash, default: node['tomcat_bin']['ssl']
attribute :ajp, kind_of: Hash, default: node['tomcat_bin']['ajp']
attribute :engine_valves, kind_of: Hash, default: node['tomcat_bin']['engine_valves']
attribute :default_host, kind_of: Hash, default: node['tomcat_bin']['default_host']
attribute :default_host_valves, kind_of: Hash, default: node['tomcat_bin']['default_host_valves']
attribute :access_log_valve, kind_of: Hash, default: node['tomcat_bin']['access_log_valve']
attribute :log_dir, kind_of: String, default: 'logs'

attribute :logs_rotatable, equal_to: [true, false], default: node['tomcat_bin']['logs_rotatable']
attribute :logrotate_count, kind_of: Integer, default: node['tomcat_bin']['logrotate_count']
attribute :logrotate_frequency, kind_of: String, default: node['tomcat_bin']['logrotate_frequency']

attribute :ulimit_nofile, kind_of: Integer, default: node['tomcat_bin']['ulimit_nofile']
attribute :ulimit_nproc, kind_of: Integer, default: node['tomcat_bin']['ulimit_nproc']

attribute :init_cookbook, kind_of: String, default: 'tomcat_bin'
attribute :setenv_cookbook, kind_of: String, default: 'tomcat_bin'
attribute :server_xml_cookbook, kind_of: String, default: 'tomcat_bin'
attribute :logging_properties_cookbook, kind_of: String, default: 'tomcat_bin'
attribute :logrotate_cookbook, kind_of: String, default: 'tomcat_bin'
