require 'spec_helper'

describe 'rabbitmq::config::cluster' do

  describe 'specifying cluster nodes and using default erlang cookie' do 
    let :params do 
      { :cluster_disk_nodes => ['hare-1', 'hare-2'],
        :wipe_db_on_cookie_change => false }
    end
    
    it 'should specify cluster nodes in fragment of rabbitmq.config' do
      verify_contents(subject, 'concat::fragment', 'fragment_config_cluster',
                      ["{rabbit, [{cluster_nodes, ['rabbit@hare-1', 'rabbit@hare-2']}]},"])
    end

    it 'should have the default erlang cookie' do
      verify_contents(subject, 'file', 'erlang_cookie',
                   ['EOKOWXQREETZSHFNTPEY'])
    end
  end
  describe 'specifying custom erlang cookie in cluster mode' do
    let :params do
      { :erlang_cookie => 'YOKOWXQREETZSHFNTPEY' }
    end

    it 'should set .erlang.cookie to the specified value' do
      verify_contents(subject, 'file', 'erlang_cookie',
              ['YOKOWXQREETZSHFNTPEY'])
    end
  end
end
