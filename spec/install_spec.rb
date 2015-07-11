# rubocop:disable Metrics/LineLength
require_relative 'spec_helper'

describe 'apache_tomcat::install' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['apache_tomcat'],
                             file_cache_path: '/var/chef') do |node|
      node.set['apache_tomcat']['mirror'] = 'https://getstuff.org/blah'
      node.set['apache_tomcat']['checksum'] = 'mychecksum'
      node.set['apache_tomcat']['version'] = '7.7.77'
      node.set['apache_tomcat']['install_path'] = '/opt/tomcat7'
    end.converge(described_recipe)
  end

  it 'installs tomcat' do
    expect(chef_run).to install_apache_tomcat('/opt/tomcat7')
  end

  it 'creates tomcat home directory' do
    expect(chef_run).to create_directory('/opt/tomcat-7.7.77').with(
      owner: 'root', group: 'root', mode: '0755')
  end

  it 'downloads tomcat' do
    expect(chef_run).to create_remote_file('/var/chef/tomcat-7.7.77.tar.gz').with(
      owner: 'root',
      group: 'root',
      checksum: 'mychecksum',
      source: 'https://getstuff.org/blah/7.7.77/tomcat-7.7.77.tar.gz')
  end

  it 'does not extract tomcat if already installed' do
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with('/opt/tomcat-7.7.77/bin').and_return(true)
    expect(chef_run).not_to run_bash('extract tomcat')
  end

  it 'extracts tomcat if not installed' do
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with('/opt/tomcat-7.7.77/bin').and_return(false)
    expect(chef_run).to run_bash('extract tomcat').with(
      user: 'root', cwd: '/var/chef')
  end

  it 'links install dir to extracted dir' do
    expect(chef_run).to create_link('/opt/tomcat7').with(
      to: '/opt/tomcat-7.7.77')
  end
end
