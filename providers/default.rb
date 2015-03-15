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

def http_connector
  return unless new_resource.http_port
  http = {
    'port' => new_resource.http_port,
    'protocol' => 'HTTP/1.1',
    'connectionTimeout' => '20000',
    'URIEncoding' => 'UTF-8'
  }
  http['executor'] = thread_pool['name'] if thread_pool
  http['redirectPort'] = new_resource.ssl_port if new_resource.ssl_port
  http.merge!(new_resource.http_additional || {})
end

def ssl_connector
  return unless new_resource.ssl_port
  ssl = {
    'port' => new_resource.ssl_port,
    'protocol' => 'HTTP/1.1',
    'connectionTimeout' => '20000',
    'URIEncoding' => 'UTF-8',
    'SSLEnabled' => 'true',
    'scheme' => 'https',
    'secure' => 'true',
    'sslProtocol' => 'TLS',
    'clientAuth' => 'false'
  }
  ssl['executor'] = thread_pool['name'] if thread_pool
  ssl.merge!(new_resource.ssl_additional || {})
end

def thread_pool
  return unless new_resource.pool_enabled
  {
    'name' => 'tomcatThreadPool',
    'namePrefix' => 'catalina-exec-'
  }.merge!(new_resource.pool_additional || {})
end

def ajp_connector
  return unless new_resource.ajp_port
  ajp = {
    'port' => new_resource.ajp_port,
    'protocol' => 'AJP/1.3',
    'URIEncoding' => 'UTF-8'
  }
  ajp['redirectPort'] = new_resource.ssl_port if new_resource.ssl_port
  ajp.merge!(new_resource.ajp_additional || {})
end

def access_log_valve
  return unless new_resource.access_log_enabled
  valve = {
    'className' => 'org.apache.catalina.valves.AccessLogValve',
    'prefix' => 'localhost_access_log.',
    'suffix' => '.log',
    'pattern' => 'common'
  }
  valve['rotatable'] = new_resource.logs_rotatable
  valve['prefix'].chomp!('.') unless new_resource.logs_rotatable
  valve.merge!(new_resource.access_log_additional || {})
  valve['directory'] = log_dir
  valve
end

def jmx_dir
  new_resource.jmx_dir || ::File.join(new_resource.home, 'conf')
end

def logs_absolute?
  ::Pathname.new(log_dir).absolute?
end

def log_dir
  new_resource.log_dir || 'logs'
end

def absolute_log_dir
  return log_dir if ::Pathname.new(log_dir).absolute?
  ::File.join(new_resource.home, log_dir)
end

def absolute_log_path(file, dir = log_dir)
  if logs_absolute?
    ::File.join(dir, file)
  else
    ::File.join(new_resource.home, dir, file)
  end
end

action :install do
  package 'gzip'

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
    only_if { nofiles || nprocs }
  end

  setenv_sh = ::File.join(new_resource.home, 'bin', 'setenv.sh')
  server_xml = ::File.join(new_resource.home, 'conf', 'server.xml')
  logging_properties =
    ::File.join(new_resource.home, 'conf', 'logging.properties')

  directory absolute_log_dir do
    not_if { log_dir == 'logs' }
    recursive true
    owner new_resource.user
    group new_resource.group
  end

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
      catalina_out_dir: log_dir == 'logs' ? nil : absolute_log_dir,
      config: new_resource
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
      thread_pool: thread_pool,
      http: http_connector,
      ssl: ssl_connector,
      ajp: ajp_connector,
      engine_valves: new_resource.engine_valves || {},
      host_valves: new_resource.host_valves || {},
      access_log_valve: access_log_valve
    )
    cookbook new_resource.server_xml_cookbook
    notifies :create, "ruby_block[restart_#{service_name}]", :immediately
  end

  template ::File.join(jmx_dir, 'jmxremote.access') do
    source 'jmxremote.access.erb'
    mode '0755'
    owner new_resource.user
    group new_resource.group
    if new_resource.jmx_port.nil? || new_resource.jmx_authenticate == false
      action :delete
    else
      action :create
    end
    notifies :create, "ruby_block[restart_#{service_name}]", :immediately
  end

  template ::File.join(jmx_dir, 'jmxremote.password') do
    source 'jmxremote.password.erb'
    mode '0600'
    owner new_resource.user
    group new_resource.group
    variables(
      control_password: new_resource.jmx_control_password,
      monitor_password: new_resource.jmx_monitor_password
    )
    if new_resource.jmx_port.nil? || new_resource.jmx_authenticate == false
      action :delete
    else
      action :create
    end
    notifies :create, "ruby_block[restart_#{service_name}]", :immediately
  end

  template logging_properties do
    source 'logging.properties.erb'
    mode 0755
    owner new_resource.user
    group new_resource.group
    variables(
      rotatable: new_resource.logs_rotatable,
      log_dir: logs_absolute? ? absolute_log_dir : "${catalina.base}/#{log_dir}"
    )
    cookbook new_resource.logging_properties_cookbook
    notifies :create, "ruby_block[restart_#{service_name}]", :immediately
  end

  logs = %w(catalina.out)
  unless new_resource.logs_rotatable
    logs.concat %w(catalina.log manager.log host-manager.log localhost.log)
  end
  log_paths = logs.map { |log| ::File.join(absolute_log_dir, log) }
  if access_log_valve
    fname = access_log_valve['prefix'] + access_log_valve['suffix']
    log_paths << ::File.join(absolute_log_dir, fname)
  end

  template "/etc/logrotate.d/#{service_name}" do
    source 'logrotate.erb'
    mode 0644
    owner 'root'
    group 'root'
    variables(
      files: log_paths,
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
