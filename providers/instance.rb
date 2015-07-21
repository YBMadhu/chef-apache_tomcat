#
# Cookbook Name:: apache_tomcat
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

action :create do
  [
    :home,
    :enable_service,
    :user,
    :group,
    :webapps_mode,
    :enable_manager,
    :kill_delay,
    :java_home,
    :catalina_opts,
    :java_opts,
    :initial_heap_size,
    :max_heap_size,
    :max_perm_size,
    :jmx_authenticate,
    :jmx_users,
    :tomcat_users,
    :pool_enabled,
    :pool_additional,
    :http_additional,
    :ssl_additional,
    :ajp_additional,
    :engine_valves,
    :host_valves,
    :access_log_enabled,
    :access_log_additional,
    :log_dir,
    :logs_rotatable,
    :logrotate_count,
    :logrotate_frequency,
    :setenv_template,
    :server_xml_template,
    :logging_properties_template,
    :tomcat_users_template,
    :logrotate_template
  ].each do |attrib|
    unless new_resource.instance_variable_get("@#{attrib}")
      new_resource.instance_variable_set("@#{attrib}", node['apache_tomcat'][attrib])
    end
  end

  base_instance = node['apache_tomcat']['base_instance'] ||
                  ::File.basename(node['apache_tomcat']['base'])

  if new_resource.instance_name == 'base'
    instance_name = base_instance
  else
    instance_name = "#{base_instance}-#{new_resource.instance_name}"
  end
  if new_resource.base
    catalina_base = new_resource.base
  else
    catalina_base =
      ::File.join(::File.dirname(node['apache_tomcat']['base']), instance_name)
  end
  catalina_home = new_resource.home

  if new_resource.log_dir
    unless ::Pathname.new(new_resource.log_dir).absolute?
      fail 'log_dir must be absolute if specified'
    end
    log_dir = new_resource.log_dir
  else
    log_dir = ::File.join(catalina_base, 'logs')
  end

  directory catalina_base do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
    not_if { catalina_home == catalina_base }
  end

  directory ::File.join(catalina_base, 'webapps') do
    owner 'root'
    group new_resource.group
    mode new_resource.webapps_mode
  end

  %w(bin conf lib).each do |dir|
    directory ::File.join(catalina_base, dir) do
      owner 'root'
      group new_resource.group
      mode '0755'
    end
  end

  %w(temp work).each do |dir|
    directory ::File.join(catalina_base, dir) do
      owner new_resource.user
      group new_resource.group
      mode '0755'
    end
  end

  %w(catalina.policy catalina.properties web.xml context.xml).each do |conf_file|
    link ::File.join(catalina_base, 'conf', conf_file) do
      to ::File.join(catalina_home, 'conf', conf_file)
      not_if { catalina_home == catalina_base }
    end
  end

  directory log_dir do
    recursive true
    owner new_resource.user
    group new_resource.group
    mode '0755'
  end

  link "link_logs_#{new_resource.name}" do
    target_file ::File.join(catalina_base, 'logs')
    to new_resource.log_dir
    not_if { new_resource.log_dir.nil? }
  end

  ruby_block "#{new_resource.name}-copy_manager" do
    block do
      ::FileUtils.cp_r("#{catalina_home}/webapps/manager", "#{catalina_base}/webapps/")
      ::FileUtils.chown_R('root', new_resource.group, "#{catalina_base}/webapps/manager")
    end
    not_if { catalina_home == catalina_base }
    only_if { new_resource.enable_manager }
    not_if { ::File.directory?("#{catalina_base}/webapps/manager") }
    if new_resource.enable_service
      notifies :restart, "poise_service[#{instance_name}]"
    end
  end

  ruby_block "#{new_resource.name}-delete_manager" do
    block do
      ::FileUtils.rm_r("#{catalina_base}/webapps/manager")
    end
    not_if { catalina_home == catalina_base }
    not_if { new_resource.enable_manager }
    only_if { ::File.directory?("#{catalina_base}/webapps/manager") }
    if new_resource.enable_service
      notifies :restart, "poise_service[#{instance_name}]"
    end
  end

  cb, src = template_source(new_resource.setenv_template, 'setenv.sh.erb')
  template ::File.join(catalina_base, 'bin', 'setenv.sh') do
    source src
    cookbook cb
    mode '0640'
    owner 'root'
    group new_resource.group
    variables(config: new_resource)
    if new_resource.enable_service
      notifies :restart, "poise_service[#{instance_name}]"
    end
  end

  cb, src = template_source(new_resource.server_xml_template, 'server.xml.erb')
  thread_pool_ = thread_pool
  http_ = http_connector
  ssl_ = ssl_connector
  ajp_ = ajp_connector
  access_log_valve_ = access_log_valve
  template ::File.join(catalina_base, 'conf', 'server.xml') do
    source src
    cookbook cb
    mode '0640'
    owner 'root'
    group new_resource.group
    variables(
      shutdown_port: new_resource.shutdown_port,
      thread_pool: thread_pool_,
      http: http_,
      ssl: ssl_,
      ajp: ajp_,
      engine_valves: new_resource.engine_valves || {},
      host_valves: new_resource.host_valves || {},
      access_log_valve: access_log_valve_
    )
    if new_resource.enable_service
      notifies :restart, "poise_service[#{instance_name}]"
    end
  end

  template ::File.join(catalina_base, 'conf', 'jmxremote.access') do
    source 'jmxremote.access.erb'
    mode '0600'
    owner new_resource.user
    group new_resource.group
    variables(jmx_users: new_resource.jmx_users || [])
    if new_resource.jmx_port.nil? || new_resource.jmx_authenticate == false
      action :delete
    else
      action :create
    end
    cookbook 'apache_tomcat'
    if new_resource.enable_service
      notifies :restart, "poise_service[#{instance_name}]"
    end
  end

  template ::File.join(catalina_base, 'conf', 'jmxremote.password') do
    source 'jmxremote.password.erb'
    mode '0600'
    owner new_resource.user
    group new_resource.group
    variables(jmx_users: new_resource.jmx_users || [])
    if new_resource.jmx_port.nil? || new_resource.jmx_authenticate == false
      action :delete
    else
      action :create
    end
    cookbook 'apache_tomcat'
    if new_resource.enable_service
      notifies :restart, "poise_service[#{instance_name}]"
    end
  end

  cb, src = template_source(new_resource.logging_properties_template,
                            'logging.properties.erb')
  template ::File.join(catalina_base, 'conf', 'logging.properties') do
    source src
    cookbook cb
    mode '0640'
    owner 'root'
    group new_resource.group
    if new_resource.enable_service
      notifies :restart, "poise_service[#{instance_name}]"
    end
  end

  cb, src = template_source(new_resource.tomcat_users_template, 'tomcat-users.xml.erb')
  template ::File.join(catalina_base, 'conf', 'tomcat-users.xml') do
    source src
    cookbook cb
    mode '640'
    owner 'root'
    group new_resource.group
    variables(
      roles: new_resource.tomcat_users.map { |item| item['roles'] }.flatten.uniq,
      users: new_resource.tomcat_users
    )
    if new_resource.enable_service
      notifies :restart, "poise_service[#{instance_name}]"
    end
  end

  logs = %w(catalina.out catalina.log manager.log
            host-manager.log localhost.log)
  log_paths = logs.map { |log| ::File.join(catalina_base, 'logs', log) }
  if access_log_valve
    fname = access_log_valve['prefix'] + access_log_valve['suffix']
    log_paths << ::File.join(catalina_base, 'logs', fname)
  end

  cb, src = template_source(new_resource.logrotate_template, 'logrotate.erb')
  template "/etc/logrotate.d/#{instance_name}" do
    source src
    cookbook cb
    mode '0644'
    owner 'root'
    group 'root'
    variables(
      files: log_paths,
      frequency: new_resource.logrotate_frequency,
      rotate: new_resource.logrotate_count
    )
  end

  poise_service instance_name do # ~FC021
    command "#{catalina_home}/bin/catalina.sh run"
    directory catalina_base
    if node['apache_tomcat']['init_provider']
      provider node['apache_tomcat']['init_provider']
    end
    user new_resource.user
    environment(
      CATALINA_HOME: catalina_home,
      CATALINA_BASE: catalina_base)
    options :sysvinit, template: 'apache_tomcat:sysvinit.erb'
    action new_resource.enable_service ? :enable : :disable
  end
end

private

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
    'prefix' => 'localhost_access_log',
    'suffix' => '.log',
    'rotatable' => 'false',
    'pattern' => 'common',
    'directory' => 'logs'
  }
  valve.merge!(new_resource.access_log_additional || {})
  valve
end

def template_source(template_attrib, default)
  return 'apache_tomcat', default unless template_attrib
  parts = template_attrib.split(/:/, 2)
  if parts.length == 2
    return parts
  else
    return new_resource.cookbook_name.to_s, parts.first
  end
end
