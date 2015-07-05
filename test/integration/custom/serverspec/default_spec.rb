# rubocop:disable Metrics/LineLength
require 'serverspec'

set :backend, :exec

describe file('/opt/tomcat7/bin/setenv.sh') do
  it { should be_file }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Xms256m"' }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Xmx512m"' }
end

describe file('/opt/tomcat7/conf/server.xml') do
  it { should be_file }
end

describe file('/opt/tomcat7/conf/logging.properties') do
  it { should be_file }
end

describe service('tomcat7') do
  it { should be_running }
end

describe port(9005) do
  it { should be_listening }
end

describe port(9009) do
  it { should be_listening }
end

describe port(9080) do
  it { should be_listening }
end

describe port(9443) do
  it { should be_listening }
end

describe file('/etc/logrotate.d/tomcat7') do
  it { should be_file }
  its(:content) { should include '/opt/tomcat7/logs/catalina.out' }
  its(:content) { should include '/opt/tomcat7/logs/catalina.log' }
  its(:content) { should include '/opt/tomcat7/logs/manager.log' }
  its(:content) { should include '/opt/tomcat7/logs/localhost.log' }
  its(:content) { should include '/opt/tomcat7/logs/host-manager.log' }
  its(:content) { should include 'rotate 12' }
  its(:content) { should include 'monthly' }
end

# describe file('/var/log/tomcat7/catalina.out') do
#   it { should be_file }
# end

describe file('/var/log/tomcat7/catalina.log') do
  it { should be_file }
end

describe file('/var/log/tomcat7/manager.log') do
  it { should be_file }
end

describe file('/var/log/tomcat7/host-manager.log') do
  it { should be_file }
end

describe file('/var/log/tomcat7/localhost.log') do
  it { should be_file }
end

describe file('/var/log/tomcat7/localhost_access_log.log') do
  it { should be_file }
end

describe port(9599) do
  it { should be_listening }
end

describe file('/opt/tomcat7/bin/setenv.sh') do
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote"' }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"' }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.authenticate=true"' }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.access.file=/opt/tomcat7/conf/jmxremote.access"' }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.password.file=/opt/tomcat7/conf/jmxremote.password"' }
end

describe file('/opt/tomcat7/conf/jmxremote.access') do
  it { should be_file }
  its(:content) { should include 'monitorRole readonly' }
  its(:content) { should include 'controlRole readwrite' }
end

describe file('/opt/tomcat7/conf/jmxremote.password') do
  it { should be_file }
  its(:content) { should include 'monitorRole mymonitorpw' }
  its(:content) { should include 'controlRole mycontrolpw' }
end
