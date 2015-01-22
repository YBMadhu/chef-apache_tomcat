# rubocop:disable Metrics/LineLength

default['tomcat_bin']['user'] = 'tomcat'
default['tomcat_bin']['group'] = 'tomcat'

default['tomcat_bin']['ulimit_nofile'] = 20_000
default['tomcat_bin']['ulimit_nproc'] = 50_000

default['tomcat_bin']['mirror']  = 'https://repository.apache.org/content/repositories/releases/org/apache/tomcat/tomcat'
default['tomcat_bin']['version'] = '7.0.56'
default['tomcat_bin']['checksum'] = 'c0ca44be20bccebbb043ccd7ab5ea4d94060fdde6bb84812f3da363955dae5bb'
default['tomcat_bin']['home'] = '/opt/tomcat'

# Logging settings
default['tomcat_bin']['log_dir'] = 'logs'
default['tomcat_bin']['logs_rotatable'] = false
default['tomcat_bin']['logrotate_frequency'] = 'weekly'
default['tomcat_bin']['logrotate_count'] = 4

# Setenv and init script settings
default['tomcat_bin']['kill_delay'] = nil
default['tomcat_bin']['catalina_opts'] = nil
default['tomcat_bin']['java_opts'] = nil
default['tomcat_bin']['java_home'] = nil
default['tomcat_bin']['setenv_additional'] = nil

# Server.xml settings
default['tomcat_bin']['shutdown_port'] = 8005
default['tomcat_bin']['http_port'] = 8080
default['tomcat_bin']['ajp_port'] = 8009
default['tomcat_bin']['ssl_port'] = nil
default['tomcat_bin']['pool_enabled'] = false
default['tomcat_bin']['access_log_enabled'] = false

default['tomcat_bin']['http_additional'] = Mash.new
default['tomcat_bin']['ajp_additional'] = Mash.new
default['tomcat_bin']['ssl_additional'] = Mash.new
default['tomcat_bin']['pool_additional'] = Mash.new
default['tomcat_bin']['access_log_additional'] = Mash.new
default['tomcat_bin']['engine_valves'] = Mash.new
default['tomcat_bin']['host_valves'] = Mash.new
