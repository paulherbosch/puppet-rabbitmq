require 'puppet'
require 'rspec-puppet'
require 'tmpdir'

def verify_contents(subject, title, expected_lines)
  content = subject.resource('file', title).send(:parameters)[:content]
  (content.split("\n") & expected_lines).should == expected_lines
end

RSpec.configure do |c|
  c.before :each do
    # Create a temporary puppet confdir area and temporary site.pp so
    # when rspec-puppet runs we don't get a puppet error.
    @puppetdir = Dir.mktmpdir
    manifestdir = File.join(@puppetdir, "manifests")
    Dir.mkdir(manifestdir)
    FileUtils.touch(File.join(manifestdir, "site.pp"))
    Puppet[:confdir] = @puppetdir
  end

  c.after :each do
    FileUtils.remove_entry_secure(@puppetdir)
  end

  #fixture_path = File.join(File.dirname(__FILE__), 'fixtures')
  #module_path = File.join(fixture_path, 'modules')
  c.module_path = File.join(File.dirname(__FILE__), 'fixtures/modules')
  #c.module_path = File.join(File.dirname(__FILE__), '../../')
end

