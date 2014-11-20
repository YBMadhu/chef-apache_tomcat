#
# Cookbook Name:: tomcat_test
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

node.normal['java']['jdk_version'] = '7'
node.normal['tomcat_bin']['install_java'] = true

node.normal['tomcat_bin']['thread_pool'] = 'tomcatThreadPool'
node.normal['tomcat_bin']['http']['port'] = 8080
node.normal['tomcat_bin']['http']['connectionTimeout'] = 20_000

node.normal['tomcat_bin']['ajp']['port'] = 8009

node.normal['tomcat_bin']['ssl']['port'] = 8443

node.normal['tomcat_bin']['additional_hosts'] = {
  'test.example.com' => {
    'appBase' => 'webapps/example_com'
  }
}

node.normal['tomcat_bin']['additional_access_logs'] = {
  'test.example.com' => {
    'prefix' => 'test.example.com_access_log.',
    'directory' => 'logs',
    'suffix' => '.log'
  }
}

include_recipe 'tomcat_bin'
