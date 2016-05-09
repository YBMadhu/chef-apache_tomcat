# rubocop:disable Metrics/LineLength
require 'serverspec'

set :backend, :exec

describe user('tomcat') do
  it { should exist }
  it { should belong_to_group 'tomcat' }
end

describe file('/opt/tomcat-7.0.56') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/opt/tomcat7') do
  it { should be_directory }
  it { should be_symlink }
  it { should be_linked_to '/opt/tomcat-7.0.56' }
end

%w(bin conf lib).each do |dir|
  describe file("/var/tomcat/#{dir}") do
    it { should be_directory }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'tomcat' }
    it { should be_mode 755 }
  end
end

%w(temp work conf/Catalina).each do |dir|
  describe file("/var/tomcat/#{dir}") do
    it { should be_directory }
    it { should be_owned_by 'tomcat' }
    it { should be_grouped_into 'tomcat' }
    it { should be_mode 755 }
  end
end

describe file('/var/tomcat/webapps') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should be_mode 755 }
end

describe file('/var/tomcat/webapps/manager') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should be_mode 755 }
end

%w(catalina.policy catalina.properties web.xml).each do |conf_file|
  describe file("/var/tomcat/conf/#{conf_file}") do
    it { should be_file }
  end
end

describe file('/var/tomcat/bin/setenv.sh') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should be_mode 640 }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Xms256m"' }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Xmx512m"' }
end

describe file('/var/tomcat/conf/server.xml') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should be_mode 640 }
end

describe file('/var/tomcat/conf/context.xml') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should be_mode 640 }
end

describe file('/var/tomcat/conf/logging.properties') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should be_mode 640 }
end

describe file('/var/tomcat/conf/tomcat-users.xml') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should be_mode 640 }
  its(:content) { should include '<role rolename="manager-gui" />' }
  its(:content) { should include '<user username="joedirt" password="mullet" roles="manager-gui" />' }
end

describe service('tomcat-default') do
  it { should be_enabled }
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

describe file('/etc/logrotate.d/tomcat-default') do
  it { should be_file }
  its(:content) { should include '/var/tomcat/logs/catalina.out' }
  its(:content) { should include '/var/tomcat/logs/catalina.log' }
  its(:content) { should include '/var/tomcat/logs/manager.log' }
  its(:content) { should include '/var/tomcat/logs/localhost.log' }
  its(:content) { should include '/var/tomcat/logs/host-manager.log' }
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

describe file('/var/tomcat/bin/setenv.sh') do
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote"' }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"' }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.authenticate=true"' }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.access.file=/var/tomcat/conf/jmxremote.access"' }
  its(:content) { should include 'CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.password.file=/var/tomcat/conf/jmxremote.password"' }
end

describe file('/var/tomcat/conf/jmxremote.access') do
  it { should be_file }
  its(:content) { should include 'monitorRole readonly' }
  its(:content) { should include 'controlRole readwrite' }
end

describe file('/var/tomcat/conf/jmxremote.password') do
  it { should be_file }
  its(:content) { should include 'monitorRole mymonitorpw' }
  its(:content) { should include 'controlRole mycontrolpw' }
end
