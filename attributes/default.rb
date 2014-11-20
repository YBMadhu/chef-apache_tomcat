# rubocop:disable Metrics/LineLength

default['tomcat_bin']['user'] = 'tomcat'
default['tomcat_bin']['group'] = 'tomcat'

default['tomcat_bin']['mirror']  = 'https://repository.apache.org/content/repositories/releases/org/apache/tomcat/tomcat'
default['tomcat_bin']['version'] = '7.0.56'
default['tomcat_bin']['checksum'] = 'c0ca44be20bccebbb043ccd7ab5ea4d94060fdde6bb84812f3da363955dae5bb'
default['tomcat_bin']['install_dir']  = '/opt'

# Install java using java community cookbook
default['tomcat_bin']['install_java'] = false

# Use logrotate LWRP to rotate tomcat logs
default['tomcat_bin']['use_logrotate'] = true

default['tomcat_bin']['catalina_opts'] = nil
default['tomcat_bin']['java_opts'] = nil
default['tomcat_bin']['java_home'] = nil

# Server.xml settings
default['tomcat_bin']['shutdown_port'] = 8005
default['tomcat_bin']['engine_valves'] = Mash.new
default['tomcat_bin']['default_host_valves'] = Mash.new

default['tomcat_bin']['default_host']['name'] = 'localhost'
default['tomcat_bin']['default_host']['appBase'] = 'webapps'
default['tomcat_bin']['default_host']['unpackWARs'] = true
default['tomcat_bin']['default_host']['autoDeploy'] = true

# default['tomcat_bin']['thread_pool'] = 'tomcatThreadPool'
# default['tomcat_bin']['http']['port'] = 8080
# default['tomcat_bin']['ssl']['port'] = 8443
# default['tomcat_bin']['ajp']['port'] = 8009

default['tomcat_bin']['access_log_valve']['directory'] = 'logs'
default['tomcat_bin']['access_log_valve']['suffix'] = '.log'
if node['tomcat_bin']['use_logrotate']
  default['tomcat_bin']['access_log_valve']['prefix'] = 'localhost_access_log'
  default['tomcat_bin']['access_log_valve']['rotatable'] = false
else
  default['tomcat_bin']['access_log_valve']['prefix'] = 'localhost_access_log.'
  default['tomcat_bin']['access_log_valve']['pattern'] = '%h %l %u %t &quot;%r&quot; %s %b'
  default['tomcat_bin']['access_log_valve']['rotatable'] = true
end

# default['tomcat_bin']['connectors']['8080'] = {
#   'protocol' => 'org.apache.coyote.http11.Http11NioProtocol',
#   'proxyPort' => '80',
#   'connectionTimeout' => '20000',
#   'redirectPort' => '8443',
#   'URIEncoding' => 'UTF-8',
#   'executor' => 'tomcatThreadPool'
# }
# default['tomcat_bin']['connectors']['8009'] = {
#   'protocol' => 'AJP/1.3',
#   'redirectPort' => '8443'
# }
# default['tomcat_bin']['executors'] = {
#   'name' => 'tomcatThreadPool',
#   'namePrefix' => 'catalina-exec',
#   'maxThreads' => '250',
#   'minSpareThreads' => '25'
# }
# default['tomcat_bin']['engine_valves']['org.apache.catalina.valves.RemoteIpValve'] = {
#   'internalProxies' => '127\.0\.0\.1|10\.0\.0\.162',
#   'protocolHeader' => 'x-forwarded-proto',
#   'portHeader' => 'x-forwarded-port'
# }
