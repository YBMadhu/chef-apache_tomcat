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

describe file('/opt/tomcat') do
  it { should be_directory }
  it { should be_symlink }
  it { should be_linked_to '/opt/tomcat-7.0.56' }
end

%w(bin conf lib).each do |dir|
  describe file("/opt/tomcat/#{dir}") do
    it { should be_directory }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'tomcat' }
    it { should be_mode 755 }
  end
end

%w(temp work conf/Catalina).each do |dir|
  describe file("/opt/tomcat/#{dir}") do
    it { should be_directory }
    it { should be_owned_by 'tomcat' }
    it { should be_grouped_into 'tomcat' }
    it { should be_mode 755 }
  end
end

describe file('/opt/tomcat/webapps') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should be_mode 775 }
end

describe file('/opt/tomcat/webapps/manager') do
  it { should be_directory }
end

%w(catalina.policy catalina.properties web.xml).each do |conf_file|
  describe file("/opt/tomcat/conf/#{conf_file}") do
    it { should be_file }
  end
end

describe file('/opt/tomcat/bin/setenv.sh') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should  be_mode 640 }
end

describe file('/opt/tomcat/conf/server.xml') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should  be_mode 640 }
end

describe file('/opt/tomcat/conf/context.xml') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should  be_mode 640 }
end

describe file('/opt/tomcat/conf/logging.properties') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should  be_mode 640 }
end

describe file('/opt/tomcat/conf/tomcat-users.xml') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
  it { should  be_mode 640 }
  its(:content) { should include "<tomcat-users>\n</tomcat-users>" }
end

describe service('tomcat') do
  it { should be_enabled }
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

# describe file('/opt/tomcat/logs/catalina.out') do
#   it { should be_file }
# end

describe file('/opt/tomcat/logs/catalina.log') do
  it { should be_file }
end

describe file('/opt/tomcat/logs/manager.log') do
  it { should be_file }
end

describe file('/opt/tomcat/logs/localhost.log') do
  it { should be_file }
end

describe file('/opt/tomcat/logs/localhost_access_log.log') do
  it { should_not be_file }
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
