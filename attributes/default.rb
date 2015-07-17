# rubocop:disable Metrics/LineLength

# Default installation settings - intall recipe and apache_tomcat LWRP
default['apache_tomcat']['mirror']  = 'https://repository.apache.org/content/repositories/releases/org/apache/tomcat/tomcat'
default['apache_tomcat']['version'] = '7.0.56'
default['apache_tomcat']['checksum'] = 'c0ca44be20bccebbb043ccd7ab5ea4d94060fdde6bb84812f3da363955dae5bb'

default['apache_tomcat']['home'] = '/usr/local/tomcat'
default['apache_tomcat']['base'] = '/var/lib/tomcat'
# default['apache_tomcat']['base_instance'] = ::File.basename(node['apache_tomcat']['base'])

default['apache_tomcat']['run_base_instance'] = true
default['apache_tomcat']['create_service_user'] = true

default['apache_tomcat']['instances'] = Mash.new
