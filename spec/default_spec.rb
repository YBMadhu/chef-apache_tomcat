# rubocop:disable Metrics/LineLength
require_relative 'spec_helper'

describe 'apache_tomcat::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |_node|
      # node attributes here
    end.converge(described_recipe)
  end

  it 'includes the logrotate default recipe' do
    expect(chef_run).to include_recipe('logrotate::default')
  end

  it 'includes the install recipe' do
    expect(chef_run).to include_recipe('apache_tomcat::install')
  end

  it 'includes the configure recipe' do
    expect(chef_run).to include_recipe('apache_tomcat::configure')
  end

  it 'installs tomcat' do
    expect(chef_run).to install_apache_tomcat('/usr/local/tomcat')
  end

  it 'creates tomcat instance' do
    expect(chef_run).to create_apache_tomcat_instance('/var/lib/tomcat')
  end
end
