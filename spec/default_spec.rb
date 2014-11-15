require_relative 'spec_helper'

describe 'tomcat_bin::default' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['tomcat_bin']['mirror'] = 'https://getstuff.org/blah'
      node.set['tomcat_bin']['checksum'] =
        'c0ca44be20bccebbb043ccd7ab5ea4d94060fdde6bb84812f3da363955dae5bb'
      node.set['tomcat_bin']['version'] = '7.7.77'
      node.set['tomcat_bin']['install_dir'] = '/var'
    end.converge(described_recipe)
  end

  it 'creates tomcat user' do
    expect(chef_run).to create_user('tomcat')
  end

  it 'creates tomcat group' do
    expect(chef_run).to create_group('tomcat')
  end

  it 'puts tomcat binaries with ark' do
    expect(chef_run).to put_ark('tomcat7').with(
      url: 'https://getstuff.org/blah/7.7.77/tomcat-7.7.77.tar.gz',
      checksum:
        'c0ca44be20bccebbb043ccd7ab5ea4d94060fdde6bb84812f3da363955dae5bb',
      version: '7.7.77',
      path: '/var',
      owner: 'tomcat',
      group: 'tomcat')
  end

  it 'creates tomcat init template' do
    expect(chef_run).to create_template('/etc/init.d/tomcat7').with(
      mode: 0755,
      owner: 'root',
      group: 'root',
      source: 'tomcat.init.erb')
  end

  it 'creates setenv.sh template' do
    expect(chef_run).to create_template('/var/tomcat7/bin/setenv.sh').with(
      mode: 0755,
      owner: 'tomcat',
      group: 'tomcat',
      source: 'setenv.sh.erb')
  end

  it 'creates server.xml template' do
    expect(chef_run).to create_template('/var/tomcat7/conf/server.xml').with(
      mode: 0755,
      owner: 'tomcat',
      group: 'tomcat',
      source: 'server.xml.erb')
  end

  it 'creates logging.properties template' do
    expect(chef_run).to create_template('/var/tomcat7/conf/logging.properties')
      .with(
        mode: 0755,
        owner: 'tomcat',
        group: 'tomcat',
        source: 'logging.properties.erb')
  end

  it 'enables tomcat service' do
    expect(chef_run).to enable_service('tomcat7')
  end

  it 'starts tomcat service' do
    expect(chef_run).to start_service('tomcat7')
  end

  it 'enables tomcat logrotate config' do
    expect(chef_run).to enable_logrotate_app('tomcat7').with(
      options: %w(missingok compress delaycompress copytruncate notifempty),
      frequency: 'weekly',
      rotate: 4,
      create: '0440 tomcat root')
  end
end
