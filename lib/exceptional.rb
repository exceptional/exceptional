$:.unshift File.dirname(__FILE__)

require 'exceptional/catcher'
require 'exceptional/startup'
require 'exceptional/log_factory'
require 'exceptional/config'
require 'exceptional/application_environment'
require 'exceptional/exception_data'
require 'exceptional/controller_exception_data'
require 'exceptional/remote'

module Exceptional
  PROTOCOL_VERSION = 5
  VERSION = '0.2.1'
  CLIENT_NAME = 'getexceptional-rails-plugin'

  def self.logger
    ::Exceptional::LogFactory.logger
  end

  def self.configure(api_key)
    Exceptional::Config.api_key = api_key
  end

  def self.rescue(name=nil, &block)
    begin
      block.call
    rescue Exception => e
      Exceptional::Catcher.handle_without_controller(e,name)
      Thread.current[:exceptional_context] = nil
      raise(e)
    end
  end

  def self.context(hash = {})
    Thread.current[:exceptional_context] ||= {}
    Thread.current[:exceptional_context].merge!(hash)
  end
end