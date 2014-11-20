#
# Cookbook Name:: tomcat_bin
# Provider:: default
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

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

def load_current_resource
end

action :install do
  create_user_group
  version = new_resource.version

  ark new_resource.name do
    url "#{new_resource.mirror}/#{version}/tomcat-#{version}.tar.gz"
    checksum new_resource.checksum
    version version
    path new_resource.install_dir
    owner new_resource.user
    group new_resource.group
    action :put
  end
end

action :configure do

  create_user_group

  template "/etc/init.d/#{new_resource.name}" do
    source 'tomcat.init.erb'
    variables(
      tomcat_home: new_resource.home,
      tomcat_user: new_resource.user,
      tomcat_name: new_resource.name
    )
    mode 0755
    owner 'root'
    group 'root'
    cookbook new_resource.init_template_cookbook
  end

  template ::File.join(new_resource.home, 'bin', 'setenv.sh') do
    source 'setenv.sh.erb'
    mode 0755
    owner new_resource.user
    group new_resource.group
    variables(
      tomcat_home: new_resource.home,
      java_home: new_resource.java_home,
      catalina_opts: new_resource.catalina_opts,
      java_opts: new_resource.java_opts,
      additional: new_resource.setenv_opts
    )
    cookbook new_resource.setenv_template_cookbook
  end

  template ::File.join(new_resource.home, 'conf', 'server.xml') do
    source 'server.xml.erb'
    mode 0755
    owner new_resource.user
    group new_resource.group
    variables(
      shutdown_port: new_resource.shutdown_port,
      thread_pool: new_resource.thread_pool,
      http: new_resource.http,
      ssl: new_resource.ssl,
      ajp: new_resource.ajp,
      engine_valves: new_resource.engine_valves,
      default_host: new_resource.default_host,
      default_host_valves: new_resource.default_host_valves,
      access_log_valve: new_resource.access_log_valve,
      additional_hosts: new_resource.additional_hosts,
      additional_access_logs: new_resource.additional_access_logs
    )
    cookbook new_resource.server_xml_template_cookbook
  end

end

private

def create_user_group
  group new_resource.group

  user new_resource.user do
    system true
    group new_resource.group
    shell '/bin/bash'
  end
end
