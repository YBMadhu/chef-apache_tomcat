require 'serverspec'

set :backend, :exec

describe file('/opt/tomcat7/bin/setenv.sh') do
  it { should be_file }
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
  its(:content) { should match %r{/var/log/tomcat7/catalina.out} }
  its(:content) { should match %r{/var/log/tomcat7/catalina.log} }
  its(:content) { should match %r{/var/log/tomcat7/manager.log} }
  its(:content) { should match %r{/var/log/tomcat7/localhost.log} }
  its(:content) { should match %r{/var/log/tomcat7/host-manager.log} }
  its(:content) { should match(/rotate 12/) }
  its(:content) { should match(/monthly/) }
end

describe file('/var/log/tomcat7/catalina.out') do
  it { should be_file }
end

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
