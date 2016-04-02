# rubocop:disable Metrics/LineLength

# Default installation settings
default['apache_tomcat']['mirror']  = 'https://repository.apache.org/content/repositories/releases/org/apache/tomcat/tomcat'
default['apache_tomcat']['version'] = '7.0.56'
default['apache_tomcat']['checksum'] = 'c0ca44be20bccebbb043ccd7ab5ea4d94060fdde6bb84812f3da363955dae5bb'

default['apache_tomcat']['home'] = '/usr/local/tomcat'
default['apache_tomcat']['base'] = '/var/lib/tomcat'
# base instance name, computed default shown below
# default['apache_tomcat']['base_instance'] = ::File.basename(node['apache_tomcat']['base'])
default['apache_tomcat']['run_base_instance'] = true
default['apache_tomcat']['create_service_user'] = true

# To define multiple instances
default['apache_tomcat']['instances'] = Mash.new

## INSTANCE DEFAULT SETTINGS BELOW

# Only used in base instance - if run_base_instance true
default['apache_tomcat']['shutdown_port'] = 8005
default['apache_tomcat']['http_port'] = 8080
default['apache_tomcat']['ajp_port'] = 8009
default['apache_tomcat']['ssl_port'] = nil
default['apache_tomcat']['jmx_port'] = nil
default['apache_tomcat']['debug_port'] = nil

# General instance settings
default['apache_tomcat']['user'] = 'tomcat'
default['apache_tomcat']['group'] = 'tomcat'
default['apache_tomcat']['service_name'] = nil
default['apache_tomcat']['enable_service'] = true
default['apache_tomcat']['webapps_mode'] = '0775'
default['apache_tomcat']['conf_mode'] = '0640'
default['apache_tomcat']['enable_manager'] = false

# Logging settings
default['apache_tomcat']['log_dir'] = nil
default['apache_tomcat']['logrotate_frequency'] = 'weekly'
default['apache_tomcat']['logrotate_count'] = 4

# Setenv and init script settings
default['apache_tomcat']['kill_delay'] = nil
default['apache_tomcat']['catalina_opts'] = nil
default['apache_tomcat']['java_opts'] = nil
default['apache_tomcat']['java_home'] = nil
default['apache_tomcat']['setenv_additional'] = nil
default['apache_tomcat']['initial_heap_size'] = nil
default['apache_tomcat']['max_heap_size'] = nil
default['apache_tomcat']['max_perm_size'] = nil
default['apache_tomcat']['setenv_additional'] = nil

# JMX settings
default['apache_tomcat']['jmx_authenticate'] = true
default['apache_tomcat']['jmx_users'] = {}

# Additinal server.xml settings
default['apache_tomcat']['shutdown_command'] = 'SHUTDOWN'
default['apache_tomcat']['pool_enabled'] = false
default['apache_tomcat']['access_log_enabled'] = false
default['apache_tomcat']['http_additional'] = Mash.new
default['apache_tomcat']['ajp_additional'] = Mash.new
default['apache_tomcat']['ssl_additional'] = Mash.new
default['apache_tomcat']['pool_additional'] = Mash.new
default['apache_tomcat']['access_log_additional'] = Mash.new
default['apache_tomcat']['engine_valves'] = Mash.new
default['apache_tomcat']['host_valves'] = Mash.new

# Tomcat-users.xml settings
default['apache_tomcat']['tomcat_users'] = []

# Context.xml entries
default['apache_tomcat']['context_entries'] = []

# custom templates - template or cookbook:template
default['apache_tomcat']['setenv_template'] = nil
default['apache_tomcat']['server_xml_template'] = nil
default['apache_tomcat']['logging_properties_template'] = nil
default['apache_tomcat']['tomcat_users_template'] = nil
default['apache_tomcat']['context_template'] = nil
default['apache_tomcat']['logrotate_template'] = nil

# Override init wierdnesses since poise-service
# defaults to Upstart on platforms it probably shouldn't
default['apache_tomcat']['init_provider'] = value_for_platform(
  %w(centos redhat) => {
    '< 7.0' => :sysvinit
  },
  'amazon' => {
    'default' => :sysvinit
  }
)
