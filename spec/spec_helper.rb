require 'rspec-puppet'
require 'mocha'

def verify_contents(subject, type, title, expected_lines)
  content = subject.resource(type, title).send(:parameters)[:content]
  (content.split("\n") & expected_lines).should == expected_lines
end

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.mock_with :mocha
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end
