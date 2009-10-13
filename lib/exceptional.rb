$:.unshift File.dirname(__FILE__)

require 'exceptional/catcher'
require 'exceptional/startup'
require 'exceptional/logger'
require 'exceptional/config'
require 'exceptional/exception_data'
require 'exceptional/remote'

module Exceptional
  PROTOCOL_VERSION = 5
  VERSION = '0.2.0'
  CLIENT_NAME = 'getexceptional-rails-plugin'

  def self.logger
    ::Exceptional::Logger.logger
  end
end