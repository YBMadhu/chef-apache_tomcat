# rubocop:disable Metrics/LineLength
require_relative '../spec_helper'

describe 'apache_tomcat::default' do
  let(:create_service_user) { false }
  let(:run_base_instance) { false }
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['apache_tomcat']['create_service_user'] = create_service_user
      node.set['apache_tomcat']['run_base_instance'] = run_base_instance
    end.converge(described_recipe)
  end

  context 'with create_service_user' do
    context 'when true' do
      let(:create_service_user) { true }

      it 'creates group' do
        expect(chef_run).to create_group('tomcat')
      end

      it 'creates user' do
        expect(chef_run).to create_user('tomcat')
      end
    end

    context 'when false' do
      let(:create_service_user) { false }

      it 'does not create group' do
        expect(chef_run).not_to create_group('tomcat')
      end

      it 'does not create user' do
        expect(chef_run).not_to create_user('tomcat')
      end
    end
  end

  it 'installs tomcat' do
    expect(chef_run).to install_apache_tomcat('/usr/local/tomcat')
  end

  context 'with run_base_instance' do
    context 'when true' do
      let(:run_base_instance) { true }
      it 'creates tomcat instance' do
        expect(chef_run).to create_apache_tomcat_instance('tomcat')
      end
    end

    context 'when false' do
      let(:run_base_instance) { false }
      it 'does not create tomcat instance' do
        expect(chef_run).not_to create_apache_tomcat_instance('tomcat')
      end
    end
  end
end
