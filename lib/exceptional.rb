$:.unshift File.dirname(__FILE__)


require 'exceptional/exception_data'
require 'exceptional/version'
require 'exceptional/log'
require 'exceptional/config'
require 'exceptional/remote'
require 'exceptional/handler'


module Exceptional

  class << self
    include Exceptional::Config
    include Exceptional::ExceptionalHandler
    include Exceptional::Remote
    include Exceptional::Log
    
    # called from init.rb
    def setup(environment, application_root)
      begin
        setup_config(environment, File.join(application_root,"config", "exceptional.yml"))
        setup_log(File.join(application_root, "log"), log_level)

        if enabled?
          if authenticate
            require File.join('exceptional', 'integration', 'rails')
          else
            STDERR.puts "Exceptional plugin not authenticated, check your API Key"
          end
        end        
      rescue Exception => e
        STDERR.puts e
        STDERR.puts "Exceptional Plugin disabled."
      end
    end
  end
end