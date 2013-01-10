require 'spec_helper'

describe 'rabbitmq::server' do

  let :facts do
    # Needed for statement in rabbitmq.config template.
    { :puppetversion => '2.7.14' } 
  end

  describe 'package with default params' do
    it { should contain_package('rabbitmq-server').with(
      'ensure' => 'present'
    ) }
  end

  describe 'package with specified ensure' do
  	let :params do 
  	  { :version => "2.3.0" }
  	end
  	it { should contain_package('rabbitmq-server').with(
      'ensure' => '2.3.0'
    ) }
  end

  describe 'not deleting guest user by default' do
  	it { should_not contain_rabbitmq_user('guest') }
  end

  describe 'deleting guest user' do
  	let :params do 
  	  { :delete_guest_user => true }
  	end
  	it { should contain_rabbitmq_user('guest').with(
  	  'ensure'   => 'absent',
  	  'provider' => 'rabbitmqctl'
  	) }
  end

  describe 'default service include' do
  	it { should contain_class('rabbitmq::service').with(
  	  'service_name' => 'rabbitmq-server',
  	  'ensure'       => 'running'
  	) }
  end

  describe 'overriding service paramters' do
  	let :params do
  	  { 'service_name' => 'custom-rabbitmq-server',
        'service_ensure' => 'stopped'
      }
  	end
  	it { should contain_class('rabbitmq::service').with(
  	  'service_name' => 'custom-rabbitmq-server',
  	  'ensure'       => 'stopped'
  	) }
  end

  describe 'specifing node_ip_address' do
  	let :params do
  	  { :node_ip_address => '172.0.0.1' }
  	end
    it 'should set RABBITMQ_NODE_IP_ADDRESS to specified value' do
      verify_contents(subject, 'file', 'rabbitmq-env.config',
        ['RABBITMQ_NODE_IP_ADDRESS=172.0.0.1'])
    end
  end

end
