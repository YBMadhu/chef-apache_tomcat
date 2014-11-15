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

node.normal['tomcat_bin']['install_java'] = true

node.normal['tomcat_bin']['connectors']['8080']['protocol'] = 'HTTP/1.1'
node.normal['tomcat_bin']['connectors']['8080']['redirectPort'] = 8443
node.normal['tomcat_bin']['connectors']['8080']['connectionTimeout'] = 20_000

node.normal['tomcat_bin']['connectors']['8009']['protocol'] = 'AJP/1.3'
node.normal['tomcat_bin']['connectors']['8009']['redirectPort'] = '8443'

include_recipe 'tomcat_bin'
