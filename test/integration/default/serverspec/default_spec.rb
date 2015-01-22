require 'serverspec'

set :backend, :exec

describe file('/opt/tomcat/bin/setenv.sh') do
  it { should be_file }
end

describe file('/opt/tomcat/conf/server.xml') do
  it { should be_file }
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
  its(:content) { should match %r{/opt/tomcat/logs/catalina.out} }
  its(:content) { should match %r{/opt/tomcat/logs/catalina.log} }
  its(:content) { should match %r{/opt/tomcat/logs/manager.log} }
  its(:content) { should match %r{/opt/tomcat/logs/localhost.log} }
  its(:content) { should match %r{/opt/tomcat/logs/host-manager.log} }
  its(:content) { should match(/rotate 4/) }
  its(:content) { should match(/weekly/) }
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
