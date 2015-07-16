#
# Cookbook Name:: apache_tomcat
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

actions :create
default_action :create

attribute :base, kind_of: String, name_attribute: true, required: true
attribute :home, kind_of: String, required: true
attribute :service_name, kind_of: String

attribute :shutdown_port, kind_of: Integer
attribute :http_port, kind_of: Integer
attribute :ssl_port, kind_of: Integer
attribute :ajp_port, kind_of: Integer
attribute :jmx_port, kind_of: Integer

attribute :home, kind_of: String
attribute :enable_service, equal_to: [true, false]
attribute :user, kind_of: String
attribute :group, kind_of: String
attribute :webapps_mode, kind_of: String
attribute :enable_manager, equal_to: [true, false]
attribute :kill_delay, regex: /^[1-9][0-9]?$/
attribute :java_home, kind_of: String
attribute :catalina_opts, kind_of: [String, Array]
attribute :java_opts, kind_of: String
attribute :initial_heap_size, kind_of: String
attribute :max_heap_size, kind_of: String
attribute :max_perm_size, kind_of: String
attribute :jmx_authenticate, equal_to: [true, false]
attribute :jmx_monitor_password, kind_of: String
attribute :jmx_control_password, kind_of: String
attribute :jmx_dir, kind_of: String
attribute :tomcat_users, kind_of: Array
attribute :pool_enabled, equal_to: [true, false]
attribute :pool_additional, kind_of: Hash
attribute :http_additional, kind_of: Hash
attribute :ssl_additional, kind_of: Hash
attribute :ajp_additional, kind_of: Hash
attribute :engine_valves, kind_of: Hash
attribute :host_valves, kind_of: Hash
attribute :access_log_enabled, equal_to: [true, false]
attribute :access_log_additional, kind_of: Hash
attribute :log_dir, kind_of: String
attribute :logs_rotatable, equal_to: [true, false]
attribute :logrotate_count, kind_of: Integer
attribute :logrotate_frequency, kind_of: String
attribute :setenv_template, kind_of: String
attribute :server_xml_template, kind_of: String
attribute :logging_properties_template, kind_of: String
attribute :tomcat_users_template, kind_of: String
attribute :logrotate_template, kind_of: String
