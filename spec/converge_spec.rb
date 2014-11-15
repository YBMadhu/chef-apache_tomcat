require_relative 'spec_helper'

describe 'tomcat_bin::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'converges successfully' do
    chef_run # This should not raise an error
  end
end
