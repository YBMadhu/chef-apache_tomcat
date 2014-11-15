# rubocop:disable Metrics/LineLength

default['tomcat_bin']['install_java'] = false

default['tomcat_bin']['user'] = 'tomcat'
default['tomcat_bin']['group'] = 'tomcat'

default['tomcat_bin']['mirror']  = 'https://repository.apache.org/content/repositories/releases/org/apache/tomcat/tomcat'
default['tomcat_bin']['version'] = '7.0.56'
default['tomcat_bin']['checksum'] = 'c0ca44be20bccebbb043ccd7ab5ea4d94060fdde6bb84812f3da363955dae5bb'
default['tomcat_bin']['install_dir']  = '/opt'

default['tomcat_bin']['use_logrotate'] = true

default['tomcat_bin']['shutdown_port'] = '8005'

default['tomcat_bin']['catalina_opts'] = nil
default['tomcat_bin']['java_opts'] = nil
default['tomcat_bin']['java_home'] = nil

default['tomcat_bin']['connectors'] = Mash.new
default['tomcat_bin']['executors'] = Mash.new
default['tomcat_bin']['engine_valves'] = Mash.new
default['tomcat_bin']['host_valves'] = Mash.new

# default['tomcat_bin']['connectors']['8080']['protocol'] = 'HTTP/1.1'
# default['tomcat_bin']['connectors']['8080']['redirectPort'] = '8443'
# default['tomcat_bin']['connectors']['8080']['connectionTimeout'] = '20000'

# default['tomcat_bin']['connectors']['8443']['protocol'] = 'org.apache.coyote.http11.Http11Protocol'
# default['tomcat_bin']['connectors']['8443']['maxThreads'] = 150
# default['tomcat_bin']['connectors']['8443']['SSLEnabled'] = true
# default['tomcat_bin']['connectors']['8443']['scheme'] = 'https'
# default['tomcat_bin']['connectors']['8443']['clientAuth'] = false
# default['tomcat_bin']['connectors']['8443']['sslProtocol'] = 'TLS'

# default['tomcat_bin']['connectors']['8009']['protocol'] = 'AJP/1.3'
# default['tomcat_bin']['connectors']['8009']['redirectPort'] = '8443'

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
