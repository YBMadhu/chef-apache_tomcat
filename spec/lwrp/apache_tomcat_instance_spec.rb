# rubocop:disable Metrics/LineLength
require_relative '../spec_helper'

describe 'tomcat_test::instance_lwrp' do
  let(:initial_heap_size) { nil }
  let(:max_heap_size) { nil }
  let(:max_perm_size) { nil }
  let(:catalina_opts) { nil }
  let(:jmx_port) { nil }
  let(:jmx_monitor_password) { nil }
  let(:jmx_control_password) { nil }
  let(:jmx_authenticate) { true }
  let(:java_opts) { nil }
  let(:log_dir) { nil }
  let(:enable_service) { true }
  let(:tomcat_users) { nil }
  let(:setenv_template) { nil }
  let(:server_xml_template) { nil }
  let(:logging_properties_template) { nil }
  let(:logrotate_template) { nil }
  let(:tomcat_users_template) { nil }
  let(:tomcat_home) { '/opt/tomcat7' }
  let(:instance_base) { '/var/tomcat7' }
  let(:webapps_mode) { '0666' }
  let(:enable_manager) { false }
  let(:instance_name) { nil }
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['apache_tomcat_instance'],
                             file_cache_path: '/var/chef') do |node|
      node.set['apache_tomcat']['home'] = tomcat_home
      node.set['apache_tomcat']['base'] = '/var/tomcat7'
      node.set['apache_tomcat']['logs_rotatable'] = false
      node.set['apache_tomcat']['logrotate_frequency'] = 'daily'
      node.set['apache_tomcat']['logrotate_rotate'] = 7
      node.set['apache_tomcat']['log_dir'] = log_dir
      node.set['apache_tomcat']['initial_heap_size'] = initial_heap_size
      node.set['apache_tomcat']['max_heap_size'] = max_heap_size
      node.set['apache_tomcat']['max_perm_size'] = max_perm_size
      node.set['apache_tomcat']['catalina_opts'] = catalina_opts
      node.set['apache_tomcat']['java_opts'] = java_opts
      node.set['apache_tomcat']['jmx_port'] = jmx_port
      node.set['apache_tomcat']['jmx_authenticate'] = jmx_authenticate
      node.set['apache_tomcat']['jmx_monitor_password'] = jmx_monitor_password
      node.set['apache_tomcat']['jmx_control_password'] = jmx_control_password
      node.set['apache_tomcat']['enable_service'] = enable_service
      node.set['apache_tomcat']['tomcat_users'] = tomcat_users
      node.set['apache_tomcat']['setenv_template'] = setenv_template
      node.set['apache_tomcat']['server_xml_template'] = server_xml_template
      node.set['apache_tomcat']['logging_properties_template'] = logging_properties_template
      node.set['apache_tomcat']['logrotate_template'] = logrotate_template
      node.set['apache_tomcat']['tomcat_users_template'] = tomcat_users_template
      node.set['apache_tomcat']['webapps_mode'] = webapps_mode
      node.set['apache_tomcat']['enable_manager'] = enable_manager
      node.set['tomcat_test']['instance_name'] = instance_name
      node.set['tomcat_test']['base'] = instance_base
    end.converge(described_recipe)
  end

  let(:setenv_resource) { chef_run.template('/var/tomcat7/bin/setenv.sh') }
  let(:serverxml_resource) { chef_run.template('/var/tomcat7/conf/server.xml') }
  let(:logprop_resource) { chef_run.template('/var/tomcat7/conf/logging.properties') }
  let(:tomcat_users_resource) { chef_run.template('/var/tomcat7/conf/tomcat-users.xml') }
  let(:jmxaccess_resource) { chef_run.template('/var/tomcat7/conf/jmxremote.access') }
  let(:jmxpassword_resource) { chef_run.template('/var/tomcat7/conf/jmxremote.password') }
  let(:logrotate_resource) { chef_run.template('/etc/logrotate.d/tomcat7-test') }

  {
    '/var/tomcat7' => '/var/tomcat7',
    nil => '/var/tomcat7-test'
  }.each do |base, path|
    context "when base is #{base.inspect}" do
      let(:instance_base) { base }

      it 'creates instance' do
        expect(chef_run).to create_apache_tomcat_instance('test')
      end

      it 'creates tomcat catalina_base directory' do
        expect(chef_run).to create_directory(path).with(
          owner: 'tomcat', group: 'tomcat', mode: '0755')
      end

      it 'creates webapps directory' do
        expect(chef_run).to create_directory("#{path}/webapps").with(
          owner: 'root', group: 'tomcat', mode: '0666')
      end

      %w(bin conf lib).each do |dir|
        it "creates tomcat #{dir} directory" do
          expect(chef_run).to create_directory("#{path}/#{dir}").with(
            owner: 'root', group: 'tomcat', mode: '0755')
        end
      end

      %w(temp work).each do |dir|
        it "creates tomcat #{dir} directory" do
          expect(chef_run).to create_directory("#{path}/#{dir}").with(
            owner: 'tomcat', group: 'tomcat', mode: '0755')
        end
      end

      context 'when home = base' do
        let(:tomcat_home) { path }

        %w(catalina.policy catalina.properties web.xml context.xml).each do |file|
          it "does not create link to #{file}" do
            expect(chef_run).not_to create_link("#{path}/conf/#{file}")
          end
        end

        it 'does not create catalina_base directory' do
          expect(chef_run).not_to create_directory(path)
        end
      end

      context 'when home != base' do
        %w(catalina.policy catalina.properties web.xml context.xml).each do |file|
          it "creates link to #{file}" do
            expect(chef_run).to create_link("#{path}/conf/#{file}")
          end
        end
      end

      context 'when log_dir is nil' do
        it 'creates local logs dir' do
          expect(chef_run).to create_directory("#{path}/logs").with(
            owner: 'tomcat', group: 'tomcat', mode: '0755')
        end
      end

      context 'when log_dir is relative' do
        let(:log_dir) { 'logs' }
        it 'raises error' do
          expect { chef_run }.to raise_error
        end
      end

      context 'when log_dir is absolute' do
        let(:log_dir) { '/var/log/my_tomcat_logs' }
        it 'creates absolute log_dir' do
          expect(chef_run).to create_directory('/var/log/my_tomcat_logs')
        end

        it 'creates link from logs dir to absolute dir' do
          expect(chef_run).to create_link("#{path}/logs").with(
            to: '/var/log/my_tomcat_logs')
        end
      end

      it 'creates setenv.sh template' do
        expect(chef_run).to create_template("#{path}/bin/setenv.sh").with(
          mode: '0640',
          owner: 'root',
          group: 'tomcat',
          source: 'setenv.sh.erb',
          cookbook: 'apache_tomcat')
      end

      it 'creates server.xml template' do
        expect(chef_run).to create_template("#{path}/conf/server.xml").with(
          mode: '0640',
          owner: 'root',
          group: 'tomcat',
          source: 'server.xml.erb',
          cookbook: 'apache_tomcat')
      end

      it 'creates logging.properties template' do
        expect(chef_run).to create_template("#{path}/conf/logging.properties").with(
          mode: '0640',
          owner: 'root',
          group: 'tomcat',
          source: 'logging.properties.erb',
          cookbook: 'apache_tomcat')
      end

      it 'creates logrotate template' do
        expect(chef_run).to create_template('/etc/logrotate.d/tomcat7-test').with(
          mode: '0644',
          owner: 'root',
          group: 'root',
          source: 'logrotate.erb',
          cookbook: 'apache_tomcat')
      end

      it 'creates tomcat-users.xml template' do
        expect(chef_run).to create_template("#{path}/conf/tomcat-users.xml").with(
          mode: '640',
          owner: 'root',
          group: 'tomcat')
      end

      it 'jmxremote.access template has correct path' do
        expect(chef_run).to delete_template("#{path}/conf/jmxremote.access")
      end

      it 'jmxremote.password template has correct path' do
        expect(chef_run).to delete_template("#{path}/conf/jmxremote.password")
      end
    end
  end

  context 'with base instance' do
    let(:instance_name) { 'base' }
    it 'creates base instance' do
      expect(chef_run).to create_apache_tomcat_instance('test').with(
        instance_name: 'base')
    end

    it 'uses correct service name' do
      expect(chef_run). to enable_poise_service('tomcat7')
    end

    it 'creates correct logrotate template' do
      expect(chef_run).to create_template('/etc/logrotate.d/tomcat7')
    end

    it 'creates base directory' do
      expect(chef_run).to create_directory('/var/tomcat7')
    end
  end

  context 'with enable_manager' do
    context 'when false' do
      let(:enable_manager) { false }

      context 'when manager dir does not exist' do
        before do
          allow(File).to receive(:directory?).and_call_original
          allow(File).to receive(:directory?).with('/var/tomcat7/webapps/manager')
            .and_return(false)
        end

        it 'does not delete or copy manager webapp' do
          expect(chef_run).not_to run_ruby_block('tomcat_test-delete_manager')
          expect(chef_run).not_to run_ruby_block('tomcat_test-copy_manager')
        end
      end

      context 'when manager dir exists' do
        before do
          allow(File).to receive(:directory?).and_call_original
          allow(File).to receive(:directory?).with('/var/tomcat7/webapps/manager')
            .and_return(true)
        end

        it 'deletes and does not copy manager webapp' do
          expect(chef_run).to run_ruby_block('test-delete_manager')
          expect(chef_run).not_to run_ruby_block('test-copy_manager')
        end
      end
    end

    context 'when true' do
      let(:enable_manager) { true }

      context 'when manager dir does not exist' do
        before do
          allow(File).to receive(:directory?).and_call_original
          allow(File).to receive(:directory?).with('/var/tomcat7/webapps/manager')
            .and_return(false)
        end

        it 'copies and does not delete manager webapp' do
          expect(chef_run).to run_ruby_block('test-copy_manager')
          expect(chef_run).not_to run_ruby_block('test-delete_manager')
        end
      end

      context 'when manager dir exists' do
        before do
          allow(File).to receive(:directory?).and_call_original
          allow(File).to receive(:directory?).with('/var/tomcat7/webapps/manager')
            .and_return(true)
        end

        it 'does not copy or delete manager webapp' do
          expect(chef_run).not_to run_ruby_block('test-copy_manager')
          expect(chef_run).not_to run_ruby_block('test-delete_manager')
        end
      end
    end
  end

  context 'with no tomcat_users' do
    it 'tomcat-users.xml has no users or roles' do
      expect(chef_run).to render_file('/var/tomcat7/conf/tomcat-users.xml')
        .with_content("<tomcat-users>\n</tomcat-users>")
    end
  end

  context 'with specified tomcat_users' do
    let(:tomcat_users) do
      [
        { 'id' => 'bill', 'password' => 'eggs', 'roles' => %w(admin) },
        { 'id' => 'bob', 'password' => 'bacon', 'roles' => %w(admin foo) }
      ]
    end
    it 'tomcat-users.xml has roles' do
      expect(chef_run).to render_file('/var/tomcat7/conf/tomcat-users.xml')
        .with_content("<role rolename=\"admin\" />\n<role rolename=\"foo\" />")
    end

    it 'tomcat-users.xml has users' do
      expect(chef_run).to render_file('/var/tomcat7/conf/tomcat-users.xml')
        .with_content('<user username="bill" password="eggs" roles="admin" />')
      expect(chef_run).to render_file('/var/tomcat7/conf/tomcat-users.xml')
        .with_content('<user username="bob" password="bacon" roles="admin, foo" />')
    end
  end

  context 'with custom templates' do
    context 'when template name only' do
      let(:setenv_template) { 'my_setenv.erb' }
      let(:server_xml_template) { 'my_server_xml.erb' }
      let(:logging_properties_template) { 'my_logging_properties.erb' }
      let(:logrotate_template) { 'my_logrotate.erb' }
      let(:tomcat_users_template) { 'my_tomcat_users.erb' }

      it 'setenv.sh template uses correct source and cookbook' do
        expect(setenv_resource.source).to eq('my_setenv.erb')
        expect(setenv_resource.cookbook).to eq('tomcat_test')
      end

      it 'server.xml template uses correct source and cookbook' do
        expect(serverxml_resource.source).to eq('my_server_xml.erb')
        expect(serverxml_resource.cookbook).to eq('tomcat_test')
      end

      it 'logging.properties template uses correct source and cookbook' do
        expect(logprop_resource.source).to eq('my_logging_properties.erb')
        expect(logprop_resource.cookbook).to eq('tomcat_test')
      end

      it 'logrotate template uses correct source and cookbook' do
        expect(logrotate_resource.source).to eq('my_logrotate.erb')
        expect(logrotate_resource.cookbook).to eq('tomcat_test')
      end

      it 'tomcat-users template uses correct source and cookbook' do
        expect(tomcat_users_resource.source).to eq('my_tomcat_users.erb')
        expect(tomcat_users_resource.cookbook).to eq('tomcat_test')
      end
    end

    context 'when cookbook:template' do
      let(:setenv_template) { 'bar:your_setenv.erb' }
      let(:server_xml_template) { 'foo:your_server_xml.erb' }
      let(:logging_properties_template) { 'baz:your_log_prop.erb' }
      let(:logrotate_template) { 'bing:your_logrotate.erb' }
      let(:tomcat_users_template) { 'bacon:your_tomcat_users.erb' }

      it 'setenv.sh template uses correct source and cookbook' do
        expect(setenv_resource.source).to eq('your_setenv.erb')
        expect(setenv_resource.cookbook).to eq('bar')
      end

      it 'server.xml template uses correct source and cookbook' do
        expect(serverxml_resource.source).to eq('your_server_xml.erb')
        expect(serverxml_resource.cookbook).to eq('foo')
      end

      it 'logging.properties template uses correct source and cookbook' do
        expect(logprop_resource.source).to eq('your_log_prop.erb')
        expect(logprop_resource.cookbook).to eq('baz')
      end

      it 'logrotate template uses correct source and cookbook' do
        expect(logrotate_resource.source).to eq('your_logrotate.erb')
        expect(logrotate_resource.cookbook).to eq('bing')
      end

      it 'tomcat-users template uses correct source and cookbook' do
        expect(tomcat_users_resource.source).to eq('your_tomcat_users.erb')
        expect(tomcat_users_resource.cookbook).to eq('bacon')
      end
    end
  end

  context 'when enable_service true' do
    it 'enables poise-service' do
      expect(chef_run).to enable_poise_service('tomcat7-test').with(
        command: '/opt/tomcat7/bin/catalina.sh run',
        directory: '/var/tomcat7',
        user: 'tomcat',
        environment: {
          CATALINA_HOME: tomcat_home,
          CATALINA_BASE: '/var/tomcat7'
        })
    end

    it 'setenv.sh template notifies service restart' do
      expect(setenv_resource).to notify('poise_service[tomcat7-test]').to(:restart)
    end

    it 'server.xml template notifies service restart' do
      expect(serverxml_resource).to notify('poise_service[tomcat7-test]').to(:restart)
    end

    it 'logging.properties template notifies service restart' do
      expect(logprop_resource).to notify('poise_service[tomcat7-test]').to(:restart)
    end

    it 'jmxremote.access template notifies service restart' do
      expect(jmxaccess_resource).to notify('poise_service[tomcat7-test]').to(:restart)
    end

    it 'jmxremote.password template notifies service restart' do
      expect(jmxpassword_resource).to notify('poise_service[tomcat7-test]').to(:restart)
    end
  end

  context 'when enable_service false' do
    let(:enable_service) { false }
    it 'poise-service is disabled' do
      expect(chef_run).to disable_poise_service('tomcat7-test')
    end

    it 'setenv.sh template does not notify service' do
      expect(setenv_resource).not_to notify('poise_service[tomcat7-test]')
    end

    it 'server.xml template does not notify service' do
      expect(serverxml_resource).not_to notify('poise_service[tomcat7-test]')
    end

    it 'logging.properties template does not notify service' do
      expect(logprop_resource).not_to notify('poise_service[tomcat7-test]')
    end

    it 'jmxremote.access template does not notify service' do
      expect(jmxaccess_resource).not_to notify('poise_service[tomcat7-test]')
    end

    it 'jmxremote.password template does not notify service' do
      expect(jmxpassword_resource).not_to notify('poise_service[tomcat7-test]')
    end
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
      expect(chef_run).to delete_template('/var/tomcat7/conf/jmxremote.password')
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
        .with(owner: 'tomcat', group: 'tomcat', mode: '0600')
    end
    it 'creates jmxremote.password template' do
      expect(chef_run).to create_template('/var/tomcat7/conf/jmxremote.password').with(
        owner: 'tomcat',
        group: 'tomcat',
        mode: '0600')
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
        expect(chef_run).to delete_template('/var/tomcat7/conf/jmxremote.password')
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
