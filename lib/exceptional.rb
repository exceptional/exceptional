$:.unshift File.dirname(__FILE__)

require 'exceptional/catcher'
require 'exceptional/startup'
require 'exceptional/log_factory'
require 'exceptional/config'
require 'exceptional/application_environment'
require 'exceptional/exception_data'
require 'exceptional/remote'
require 'exceptional/integration/rack'

module Exceptional
  PROTOCOL_VERSION = 5
  VERSION = '0.2.0'
  CLIENT_NAME = 'getexceptional-rails-plugin'

  def self.logger
    ::Exceptional::LogFactory.logger
  end

  def self.configure(api_key)
    Exceptional::Config.api_key = api_key
  end

  def self.rescue(&block)
    begin
      block.call
    rescue Exception => e
      Exceptional::Catcher.handle(e)
      raise(e)
    end
  end
end