$:.unshift File.dirname(__FILE__)


require 'exceptional/exception_data'
require 'exceptional/version'
require 'exceptional/log'
require 'exceptional/config'
require 'exceptional/remote'
require 'exceptional/api'
require 'exceptional/bootstrap'
require 'exceptional/api_key_validation'

module Exceptional

  class << self
    include Exceptional::APIKeyValidation
    include Exceptional::Config
    include Exceptional::Api
    include Exceptional::Remote
    include Exceptional::Log
    include Exceptional::Bootstrap
  end
end