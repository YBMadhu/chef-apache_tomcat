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
