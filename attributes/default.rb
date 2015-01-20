# rubocop:disable Metrics/LineLength

default['tomcat_bin']['user'] = 'tomcat'
default['tomcat_bin']['group'] = 'tomcat'

default['tomcat_bin']['mirror']  = 'https://repository.apache.org/content/repositories/releases/org/apache/tomcat/tomcat'
default['tomcat_bin']['version'] = '7.0.56'
default['tomcat_bin']['checksum'] = 'c0ca44be20bccebbb043ccd7ab5ea4d94060fdde6bb84812f3da363955dae5bb'
default['tomcat_bin']['home'] = '/opt/tomcat'

# Install java using java community cookbook
default['tomcat_bin']['install_java'] = false

default['tomcat_bin']['log_dir'] = 'logs'
default['tomcat_bin']['logs_rotatable'] = false
default['tomcat_bin']['logrotate_frequency'] = 'weekly'
default['tomcat_bin']['logrotate_count'] = 4

default['tomcat_bin']['kill_delay'] = nil
default['tomcat_bin']['catalina_opts'] = nil
default['tomcat_bin']['java_opts'] = nil
default['tomcat_bin']['java_home'] = nil
default['tomcat_bin']['setenv_additional'] = nil

# Server.xml settings
default['tomcat_bin']['shutdown_port'] = 8005
default['tomcat_bin']['engine_valves'] = Mash.new
default['tomcat_bin']['default_host_valves'] = Mash.new

default['tomcat_bin']['default_host']['name'] = 'localhost'
default['tomcat_bin']['default_host']['appBase'] = 'webapps'
default['tomcat_bin']['default_host']['unpackWARs'] = true
default['tomcat_bin']['default_host']['autoDeploy'] = true

# default['tomcat_bin']['thread_pool'] = 'tomcatThreadPool'
default['tomcat_bin']['http']['port'] = 8080
default['tomcat_bin']['ssl']['port'] = 8443
default['tomcat_bin']['ajp']['port'] = 8009

default['tomcat_bin']['access_log_valve']['directory'] = 'logs'
default['tomcat_bin']['access_log_valve']['suffix'] = '.log'
default['tomcat_bin']['access_log_valve']['pattern'] = '%h %l %u %t &quot;%r&quot; %s %b'
if node['tomcat_bin']['logs_rotatable']
  default['tomcat_bin']['access_log_valve']['prefix'] = 'localhost_access_log.'
  default['tomcat_bin']['access_log_valve']['rotatable'] = true
else
  default['tomcat_bin']['access_log_valve']['prefix'] = 'localhost_access_log'
  default['tomcat_bin']['access_log_valve']['rotatable'] = false
end

# Tomcat user ulimits
default['tomcat_bin']['ulimit_nofile'] = 20_000
default['tomcat_bin']['ulimit_nproc'] = 50_000
