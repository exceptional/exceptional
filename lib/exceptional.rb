$:.unshift File.dirname(__FILE__)

require 'exceptional/catcher'
require 'exceptional/startup'
require 'exceptional/log_factory'
require 'exceptional/config'
require 'exceptional/application_environment'
require 'exceptional/exception_data'
require 'exceptional/controller_exception_data'
require 'exceptional/rack_exception_data'
require 'exceptional/remote'
require 'exceptional/integration/rack'
require 'exceptional/version'

module Exceptional
  PROTOCOL_VERSION = 5
  CLIENT_NAME = 'getexceptional-gem'

  def self.logger
    ::Exceptional::LogFactory.logger
  end

  def self.configure(api_key)
    Exceptional::Config.api_key = api_key
  end

  def self.handle(exception, name=nil)
    Exceptional::Catcher.handle(exception, name)
  end
  
  def self.rescue(name=nil, context=nil, &block)
    begin
      self.context(context) unless context.nil?
      block.call
    rescue Exception => e
      Exceptional::Catcher.handle(e,name)
    ensure
      self.clear!
    end
  end

  def self.rescue_and_reraise(name=nil, context=nil, &block)
    begin
      self.context(context) unless context.nil?
      block.call
    rescue Exception => e
      Exceptional::Catcher.handle(e,name)
      raise(e)
    ensure
      self.clear!      
    end
  end

  def self.clear!
    Thread.current[:exceptional_context] = nil
  end

  def self.context(hash = {})
    Thread.current[:exceptional_context] ||= {}
    Thread.current[:exceptional_context].merge!(hash)
    self
  end
end