# rubocop:disable Metrics/LineLength
require_relative 'spec_helper'

describe 'tomcat_bin::default' do
  let(:initial_heap_size) { nil }
  let(:max_heap_size) { nil }
  let(:max_perm_size) { nil }
  let(:catalina_opts) { nil }
  let(:jmx_port) { nil }
  let(:jmx_monitor_password) { nil }
  let(:jmx_control_password) { nil }
  let(:jmx_authenticate) { true }
  let(:java_opts) { nil }
  let(:log_dir) { 'my_logs' }
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['tomcat_bin'],
                             file_cache_path: '/var/chef') do |node|
      node.set['tomcat_bin']['mirror'] = 'https://getstuff.org/blah'
      node.set['tomcat_bin']['checksum'] = 'mychecksum'
      node.set['tomcat_bin']['version'] = '7.7.77'
      node.set['tomcat_bin']['home'] = '/var/tomcat7'
      node.set['tomcat_bin']['logs_rotatable'] = false
      node.set['tomcat_bin']['logrotate_frequency'] = 'daily'
      node.set['tomcat_bin']['logrotate_rotate'] = 7
      node.set['tomcat_bin']['log_dir'] = log_dir
      node.set['tomcat_bin']['initial_heap_size'] = initial_heap_size
      node.set['tomcat_bin']['max_heap_size'] = max_heap_size
      node.set['tomcat_bin']['max_perm_size'] = max_perm_size
      node.set['tomcat_bin']['catalina_opts'] = catalina_opts
      node.set['tomcat_bin']['java_opts'] = java_opts
      node.set['tomcat_bin']['jmx_port'] = jmx_port
      node.set['tomcat_bin']['jmx_authenticate'] = jmx_authenticate
      node.set['tomcat_bin']['jmx_monitor_password'] = jmx_monitor_password
      node.set['tomcat_bin']['jmx_control_password'] = jmx_control_password
    end.converge(described_recipe)
  end

  let(:init_template) { chef_run.template('/etc/init.d/tomcat7') }
  let(:setenv_template) { chef_run.template('/var/tomcat7/bin/setenv.sh') }
  let(:server_template) { chef_run.template('/var/tomcat7/conf/server.xml') }
  let(:log_template) do
    chef_run.template('/var/tomcat7/conf/logging.properties')
  end

  it 'includes the logrotate recipe' do
    expect(chef_run).to include_recipe('logrotate::default')
  end

  it 'creates tomcat user' do
    expect(chef_run).to create_user('tomcat')
  end

  it 'creates tomcat group' do
    expect(chef_run).to create_group('tomcat')
  end

  it 'creates tomcat instance' do
    expect(chef_run).to create_tomcat_bin('/var/tomcat7')
  end

  it 'creates tomcat home directory' do
    expect(chef_run).to create_directory('/var/tomcat7').with(
      owner: 'root', group: 'root', mode: '0755')
  end

  it 'downloads tomcat' do
    expect(chef_run).to create_remote_file('/var/chef/tomcat-7.7.77.tar.gz')
      .with(owner: 'root', group: 'root',
            checksum: 'mychecksum',
            source: 'https://getstuff.org/blah/7.7.77/tomcat-7.7.77.tar.gz')
  end

  it 'does not extract tomcat if already installed' do
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?)
      .with('/var/tomcat7/webapps').and_return(true)
    expect(chef_run).not_to run_bash('extract tomcat')
  end

  it 'extracts tomcat if not installed' do
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?)
      .with('/var/tomcat7/webapps').and_return(false)
    expect(chef_run).to run_bash('extract tomcat').with(
      user: 'root', cwd: '/var/chef')
  end

  %w(bin conf lib).each do |dir|
    it "creates tomcat #{dir} directory" do
      expect(chef_run).to create_directory("/var/tomcat7/#{dir}").with(
        owner: 'root', group: 'tomcat', mode: '0755')
    end
  end

  %w(temp work).each do |dir|
    it "creates tomcat #{dir} directory" do
      expect(chef_run).to create_directory("/var/tomcat7/#{dir}").with(
        owner: 'tomcat', group: 'tomcat', mode: '0755')
    end
  end

  it 'creates tomcat webapps directory' do
    expect(chef_run).to create_directory('/var/tomcat7/webapps').with(
      owner: 'root', group: 'tomcat', mode: '0775')
  end

  context 'when log_dir is relative' do
    it 'creates log_dir relative to tomcat home' do
      expect(chef_run).to create_directory('/var/tomcat7/my_logs')
    end
  end

  context 'when log_dir is absolute' do
    let(:log_dir) { '/var/log/my_tomcat_logs' }
    it 'creates absolute log_dir' do
      expect(chef_run).to create_directory('/var/log/my_tomcat_logs')
    end
  end

  it 'creates tomcat init template' do
    expect(chef_run).to create_template('/etc/init.d/tomcat7').with(
      mode: '0755',
      owner: 'root',
      group: 'root',
      source: 'tomcat.init.erb')
  end

  it 'init template notifies restart ruby_block' do
    expect(init_template).to notify('ruby_block[restart_tomcat7]').immediately
  end

  it 'creates setenv.sh template' do
    expect(chef_run).to create_template('/var/tomcat7/bin/setenv.sh').with(
      mode: '0750',
      owner: 'root',
      group: 'tomcat',
      source: 'setenv.sh.erb')
  end

  it 'setenv.sh template notifies restart ruby_block' do
    expect(setenv_template).to notify('ruby_block[restart_tomcat7]').immediately
  end

  it 'creates server.xml template' do
    expect(chef_run).to create_template('/var/tomcat7/conf/server.xml').with(
      mode: '0640',
      owner: 'root',
      group: 'tomcat',
      source: 'server.xml.erb')
  end

  it 'server.xml template notifies restart ruby_block' do
    expect(server_template).to notify('ruby_block[restart_tomcat7]').immediately
  end

  it 'creates logging.properties template' do
    expect(chef_run).to create_template('/var/tomcat7/conf/logging.properties')
      .with(
        mode: '0640',
        owner: 'root',
        group: 'tomcat',
        source: 'logging.properties.erb')
  end

  it 'logging.properties template notifies restart ruby_block' do
    expect(log_template).to notify('ruby_block[restart_tomcat7]').immediately
  end

  it 'enables tomcat service' do
    expect(chef_run).to enable_service('tomcat7')
  end

  it 'starts tomcat service' do
    expect(chef_run).to start_service('tomcat7')
  end

  it 'restart ruby_block does nothing' do
    resource = chef_run.ruby_block('restart_tomcat7')
    expect(resource).to do_nothing
  end

  it 'creates logrotate template' do
    expect(chef_run).to create_template('/etc/logrotate.d/tomcat7')
      .with(
        mode: '0644',
        owner: 'root',
        group: 'root',
        source: 'logrotate.erb')
  end

  context 'when catalina_opts is string' do
    let(:catalina_opts) { 'thing3 thing4' }
    it 'renders correct CATALINA_OPTS' do
      expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content('CATALINA_OPTS="${CATALINA_OPTS} thing3 thing4"')
    end
  end

  context 'when catalina_opts is array' do
    let(:catalina_opts) { %w(thing5 thing6) }
    it 'renders correct CATALINA_OPTS' do
      expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content('CATALINA_OPTS="${CATALINA_OPTS} thing5"')
      expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content('CATALINA_OPTS="${CATALINA_OPTS} thing6"')
    end
  end

  context 'when java_opts not set' do
    it 'setenv.sh does not include JAVA_OPTS' do
      expect(chef_run).not_to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content(/JAVA_OPTS/)
    end
  end

  context 'when java_opts is string' do
    let(:java_opts) { 'thing3 thing4' }
    it 'renders correct JAVA_OPTS' do
      expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content(/^JAVA_OPTS=\"thing3 thing4\"/)
    end
  end

  context 'when java heap options set' do
    let(:initial_heap_size) { '384m' }
    let(:max_heap_size) { '1024m' }
    let(:max_perm_size) { '256m' }

    it 'renders correct initial_heap_size in setenv.sh' do
      expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content('CATALINA_OPTS="${CATALINA_OPTS} -Xms384m"')
    end
    it 'renders correct max_heap_size in setenv.sh' do
      expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content('CATALINA_OPTS="${CATALINA_OPTS} -Xmx1024m"')
    end
    it 'renders correct max_perm_size in setenv.sh' do
      expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content('CATALINA_OPTS="${CATALINA_OPTS} -XX:MaxPermSize=256m"')
    end
  end

  context 'when java heap options nil' do
    it 'initial_heap_size not in setenv.sh' do
      expect(chef_run).not_to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content(/-Xms/)
    end
    it 'max_heap_size not in in setenv.sh' do
      expect(chef_run).not_to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content(/-Xmx/)
    end
    it 'max_perm_size not in setenv.sh' do
      expect(chef_run).not_to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content(/-XX:MaxPermSize=/)
    end
  end

  context 'when jmx_port not specified' do
    it 'deletes jmxremote.access template' do
      expect(chef_run).to delete_template('/var/tomcat7/conf/jmxremote.access')
    end
    it 'deletes jmxremote.password template' do
      expect(chef_run).to delete_template(
        '/var/tomcat7/conf/jmxremote.password')
    end
    it 'does not render jmxremote content in setenv.sh' do
      expect(chef_run).not_to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content(/jmxremote/)
    end
  end

  context 'when jmx_port specified' do
    let(:jmx_port) { 8999 }
    it 'creates jmxremote.access template' do
      expect(chef_run).to create_template('/var/tomcat7/conf/jmxremote.access')
        .with(owner: 'root', group: 'tomcat', mode: '0640')
    end
    it 'creates jmxremote.password template' do
      expect(chef_run).to create_template('/var/tomcat7/conf/jmxremote.password').with(
        owner: 'root',
        group: 'tomcat',
        mode: '0640')
    end
    it 'sets jmxremote.authenticate to true in setenv.sh' do
      expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content(' -Dcom.sun.management.jmxremote.authenticate=true')
    end
    it 'sets jmxremote.ssl to false in setenv.sh' do
      expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content(' -Dcom.sun.management.jmxremote.ssl=false')
    end
    it 'sets jmxremote.access.file in setenv.sh' do
      expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content(' -Dcom.sun.management.jmxremote.access.file=/var/tomcat7/conf/jmxremote.access')
    end
    it 'sets jmxremote.password.file in setenv.sh' do
      expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
        .with_content(' -Dcom.sun.management.jmxremote.password.file=/var/tomcat7/conf/jmxremote.password')
    end

    context 'when jmx_authenticate false' do
      let(:jmx_authenticate) { false }
      it 'deletes jmxremote.access template' do
        expect(chef_run).to delete_template(
          '/var/tomcat7/conf/jmxremote.access')
      end
      it 'deletes jmxremote.password template' do
        expect(chef_run).to delete_template(
          '/var/tomcat7/conf/jmxremote.password')
      end
      it 'sets jmxremote.authenticate to false in setenv.sh' do
        expect(chef_run).to render_file('/var/tomcat7/bin/setenv.sh')
          .with_content(' -Dcom.sun.management.jmxremote.authenticate=false')
      end
      it 'does not set jmxremote.access.file in setenv.sh' do
        expect(chef_run).not_to render_file('/var/tomcat7/bin/setenv.sh')
          .with_content('jmxremote.access.file')
      end
      it 'does not set jmxremote.password.file in setenv.sh' do
        expect(chef_run).not_to render_file('/var/tomcat7/bin/setenv.sh')
          .with_content('jmxremote.password.file')
      end
    end
  end
end
