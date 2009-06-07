require 'rubygems'

if ENV['RAILS_VER']
  gem 'rails', "=#{ENV['RAILS_VER']}"
else
  gem 'rails'
end

# TODO couple of different ways to test parts of exceptional with Rails (or a mock), reconcile them.
#require 'active_support'
# module Rails; end # Rails faker

require File.dirname(__FILE__) + '/../lib/exceptional'

Spec::Runner.configure do |config|

  #Runcoderun.com requires no output from any tests so stubbing
  config.before(:all) {
    Exceptional.stub!(:log!)
    Exceptional.stub!(:to_log)
    Exceptional.stub!(:to_stderr)        
    STDOUT.stub!(:puts)
    STDERR.stub!(:puts)
    
    def Exceptional.reset_state
      @adapter = nil
      @api_key = nil
      @api_key_validated = nil      
      @ssl_enabled = nil
      @log_level = nil
      @enabled = nil
      @remote_port = nil
      @remote_host = nil
      @applicaton_root = nil
      @adapter_name = nil
    end
  }

  config.after(:each) {
    Exceptional.reset_state    
  }

end