#!/usr/bin/env rspec

require 'spec_helper'

describe 'rabbitmq' do
  it { should contain_class 'rabbitmq' }
end
