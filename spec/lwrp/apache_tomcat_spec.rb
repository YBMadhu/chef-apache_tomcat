require_relative '../spec_helper'

describe 'tomcat_test::install_lwrp' do
  let(:mirror) { 'https://getstuff.org/blah' }
  let(:checksum) { 'mychecksum' }
  let(:version) { '7.7.77' }
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['apache_tomcat'],
                             file_cache_path: '/var/chef') do |node|
      node.set['tomcat_test']['path'] = '/opt/tomcat7'
      node.set['tomcat_test']['mirror'] = mirror
      node.set['tomcat_test']['checksum'] = checksum
      node.set['tomcat_test']['version'] = version
      node.set['apache_tomcat']['mirror'] = 'https://mymirror'
      node.set['apache_tomcat']['checksum'] = 'yourchecksum'
      node.set['apache_tomcat']['version'] = '8.8.88'
      # node.set['apache_tomcat']['home'] = '/opt/tomcat7'
    end.converge(described_recipe)
  end

  context 'with specified attributes' do
    it 'installs tomcat with specified attribs' do
      expect(chef_run).to install_apache_tomcat('test_tomcat').with(
        mirror: mirror, checksum: checksum, version: version)
    end
  end

  context 'with unspecifed attributes' do
    let(:mirror) { nil }
    let(:checksum) { nil }
    let(:version) { nil }
    it 'installs tomcat with node attribs' do
      expect(chef_run).to install_apache_tomcat('test_tomcat').with(
        mirror: 'https://mymirror', checksum: 'yourchecksum', version: '8.8.88')
    end

    it 'downloads correct tomcat' do
      expect(chef_run).to create_remote_file('/var/chef/tomcat-8.8.88.tar.gz')
    end

    it 'creates correct tomcat home directory' do
      expect(chef_run).to create_directory('/opt/tomcat-8.8.88')
    end
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
