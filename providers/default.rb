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

def service_name
  new_resource.service_name || ::File.basename(new_resource.home)
end

action :install do
  # run_context.include_recipe 'ark'

  group new_resource.group do
    system true
  end

  user new_resource.user do
    system true
    group new_resource.group
    shell '/bin/bash'
  end

  version = new_resource.version
  name = ::File.basename(new_resource.home)

  ark name do
    url "#{new_resource.mirror}/#{version}/tomcat-#{version}.tar.gz"
    checksum new_resource.checksum
    version version
    path ::File.dirname(new_resource.home)
    owner new_resource.user
    group new_resource.group
    action :put
  end
end

action :configure do
  nofiles = new_resource.ulimit_nofile
  nprocs = new_resource.ulimit_nproc
  user_ulimit new_resource.user do
    filehandle_limit nofiles
    process_limit nprocs
  end

  setenv_sh = ::File.join(new_resource.home, 'bin', 'setenv.sh')
  server_xml = ::File.join(new_resource.home, 'conf', 'server.xml')
  logging_properties =
    ::File.join(new_resource.home, 'conf', 'logging.properties')

  template "/etc/init.d/#{service_name}" do
    source 'tomcat.init.erb'
    variables(
      tomcat_home: new_resource.home,
      tomcat_user: new_resource.user,
      tomcat_name: service_name,
      kill_delay: new_resource.kill_delay
    )
    mode 0755
    owner 'root'
    group 'root'
    cookbook new_resource.init_cookbook
    notifies :create, "ruby_block[restart_#{service_name}]", :immediately
  end

  template setenv_sh do
    source 'setenv.sh.erb'
    mode 0755
    owner new_resource.user
    group new_resource.group
    variables(
      java_home: new_resource.java_home,
      catalina_opts: new_resource.catalina_opts,
      java_opts: new_resource.java_opts,
      additional: new_resource.setenv_opts
    )
    cookbook new_resource.setenv_cookbook
    notifies :create, "ruby_block[restart_#{service_name}]", :immediately
  end

  template server_xml do
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
      access_log_valve: new_resource.access_log_valve
    )
    cookbook new_resource.server_xml_cookbook
    notifies :create, "ruby_block[restart_#{service_name}]", :immediately
  end

  template logging_properties do
    source 'logging.properties.erb'
    mode 0755
    owner new_resource.user
    group new_resource.group
    variables(
      rotatable: new_resource.logs_rotatable
    )
    cookbook new_resource.logging_properties_cookbook
    notifies :create, "ruby_block[restart_#{service_name}]", :immediately
  end

  logs = %w(catalina.out)
  unless new_resource.logs_rotatable
    logs.concat [
      'catalina.log',
      'manager.log',
      'host-manager.log',
      'localhost.log',
      new_resource.access_log_valve['prefix'] +
        new_resource.access_log_valve['suffix']
    ]
  end

  template "/etc/logrotate.d/#{service_name}" do
    source 'logrotate.erb'
    mode 0644
    owner 'root'
    group 'root'
    variables(
      files: logs.map { |log| ::File.join(new_resource.home, 'logs', log) },
      frequency: new_resource.logrotate_frequency,
      rotate: new_resource.logrotate_count
    )
    cookbook new_resource.logrotate_cookbook
  end

  service service_name do
    supports restart: true, start: true, stop: true, status: true
    action [:enable, :start]
  end

  # Hack to prevent mulptiple starts/restarts on first-run
  ruby_block "restart_#{service_name}" do
    block do
      r = resources(service: service_name)
      a = Array.new(r.action)
      a << :restart unless a.include?(:restart)
      a.delete(:start) if a.include?(:restart)
      r.action(a)
    end
    action :nothing
  end
end

action :restart do
  service service_name do
    supports restart: true
    action :restart
  end
end
