require 'spec_helper' 

describe 'rabbitmq::config::stomp' do

  describe 'not configuring stomp by default' do
    it 'should specify the default stomp port in the fragment' do
      verify_contents(subject, 'concat::fragment', 'fragment_config_stomp',
                            ["% Configure the Stomp Plugin listening port", "{rabbitmq_stomp, [{tcp_listeners, [6163]} ]},"])
    end
  end

  describe 'configuring stomp' do
    let (:params) {{ :stomp_port => 5679 }} 
    
    it 'should specify the correct stomp port in the fragment' do
      verify_contents(subject, 'concat::fragment', 'fragment_config_stomp',
                            ["% Configure the Stomp Plugin listening port", "{rabbitmq_stomp, [{tcp_listeners, [5679]} ]},"])
    end
  end
end

