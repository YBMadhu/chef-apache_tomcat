require_relative '../spec_helper'

describe 'apache_tomcat::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['apache_tomcat']['create_service_user'] = false
      node.set['apache_tomcat']['run_base_instance'] = false
      node.set['apache_tomcat']['instances']['tomcat1']['base'] = '/var/lib/tomcat1'
      node.set['apache_tomcat']['instances']['tomcat1']['http_port'] = 8081
      node.set['apache_tomcat']['instances']['tomcat1']['shutdown_port'] = 8005
      node.set['apache_tomcat']['instances']['tomcat2']['base'] = '/var/lib/tomcat2'
      node.set['apache_tomcat']['instances']['tomcat2']['http_port'] = 8082
      node.set['apache_tomcat']['instances']['tomcat2']['shutdown_port'] = -1
    end.converge(described_recipe)
  end

  it 'installs tomcat' do
    expect(chef_run).to install_apache_tomcat('/usr/local/tomcat')
  end

  it 'installs tomcat1' do
    expect(chef_run).to create_apache_tomcat_instance('tomcat1').with(
      base: '/var/lib/tomcat1',
      http_port: 8081,
      shutdown_port: 8005
    )
  end

  it 'installs tomcat2' do
    expect(chef_run).to create_apache_tomcat_instance('tomcat2').with(
      base: '/var/lib/tomcat2',
      http_port: 8082,
      shutdown_port: -1
    )
  end
end
