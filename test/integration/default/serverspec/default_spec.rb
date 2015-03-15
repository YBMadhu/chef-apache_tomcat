require 'serverspec'

set :backend, :exec

describe file('/opt/tomcat/bin/setenv.sh') do
  it { should be_file }
end

describe file('/opt/tomcat/conf/server.xml') do
  it { should be_file }
  its(:content) { should_not include '-Xms' }
  its(:content) { should_not include '-Xmx' }
  its(:content) { should_not include 'jmxremote' }
end

describe file('/opt/tomcat/conf/logging.properties') do
  it { should be_file }
end

describe service('tomcat') do
  it { should be_running }
end

describe port(8005) do
  it { should be_listening }
end

describe port(8009) do
  it { should be_listening }
end

describe port(8080) do
  it { should be_listening }
end

describe file('/etc/logrotate.d/tomcat') do
  it { should be_file }
  its(:content) { should include '/opt/tomcat/logs/catalina.out' }
  its(:content) { should include '/opt/tomcat/logs/catalina.log' }
  its(:content) { should include '/opt/tomcat/logs/manager.log' }
  its(:content) { should include '/opt/tomcat/logs/localhost.log' }
  its(:content) { should include '/opt/tomcat/logs/host-manager.log' }
  its(:content) { should include 'rotate 4' }
  its(:content) { should include 'weekly' }
end

describe file('/opt/tomcat/logs/catalina.out') do
  it { should be_file }
end

describe file('/opt/tomcat/logs/catalina.log') do
  it { should be_file }
end

describe file('/opt/tomcat/logs/manager.log') do
  it { should be_file }
end

describe file('/opt/tomcat/logs/host-manager.log') do
  it { should be_file }
end

describe file('/opt/tomcat/logs/localhost.log') do
  it { should be_file }
end

describe file('/opt/tomcat/logs/localhost_access_log.log') do
  it { should_not be_file }
end

describe file('/var/run/tomcat/tomcat.pid') do
  it { should be_file }
end

describe file('/opt/tomcat/conf/server.xml') do
  its(:content) { should_not include 'jmxremote' }
end

describe file('/opt/tomcat7/conf/jmxremote.access') do
  it { should_not be_file }
end

describe file('/opt/tomcat7/conf/jmxremote.password') do
  it { should_not be_file }
end
