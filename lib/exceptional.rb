$:.unshift File.dirname(__FILE__)

require 'zlib'
require 'cgi'
require 'net/http'
require 'yaml'
require 'json' unless defined? Rails

require 'exceptional/exception_data'
require 'exceptional/version'
require 'exceptional/log'
require 'exceptional/config'
require 'exceptional/remote'


module Exceptional

  class << self

    # called from init.rb
    def startup
      Log.setup # need the log in place in case the authentication fails
      
      if Remote.authenticate
        require File.join('exceptional', 'integration', 'rails')
        Config.log_config_info
      else
        Log.log! "Exceptional plugin not authenticated, check your API Key"
        Log.log! "Disabling Exceptional Plugin."
      end
    end

    # rescue any exceptions within the given block,
    # send it to exceptional,
    # then raise
    def rescue(&block)
      begin
        block.call
      rescue Exception => e
        self.catch(e)
        raise(e)
      end
    end

    # parse an exception into an ExceptionData object
    def parse(exception)
      exception_data = ExceptionData.new
      exception_data.exception_backtrace = exception.backtrace
      exception_data.exception_message = exception.message
      exception_data.exception_class = exception.class.to_s
      exception_data
    end

    # post the given exception data to getexceptional.com
    def post(exception_data)
      hash = exception_data.to_hash
      if hash[:session]
        hash[:session].delete("initialization_options")
        hash[:session].delete("request")
      end

      Remote.post_exception(hash.to_json)
    end

    # given a regular ruby Exception class, will parse into an ExceptionData
    # object and post to getexceptional.com
    def catch(exception)
      exception_data = parse(exception)
      exception_data.controller_name = File.basename($0)
      post(exception_data)
    end

    # used with Rails, takes an exception, controller, request and parameters
    # creates an ExceptionData object
    # if Exceptional is running in :direct mode, will post to getexceptional.com
    def handle(exception, controller, request, params)
      Log.log! "Handling #{exception.message}", 'info'
      begin
        e = parse(exception)
        # Additional data for Rails Exceptions
        e.framework = "rails"
        e.controller_name = controller.controller_name
        e.action_name = controller.action_name
        e.application_root = Config.application_root
        e.occurred_at = Time.now.strftime("%Y%m%d %H:%M:%S %Z")
        e.environment = request.env.to_hash
        e.url = "#{request.protocol}#{request.host}#{request.request_uri}"
        e.environment = safe_environment(request)
        e.session = safe_session(request.session)
        e.parameters = params.to_hash

        post(e)
      rescue Exception => exception
        Log.log! "Error preparing exception data."
        Log.log! exception.message
        Log.log! exception.backtrace.join("\n"), 'debug'
      end
    end

    protected

    def safe_environment(request)
      safe_environment = request.env.to_hash
      # From Rails 2.3 these objects that cause a circular reference error on .to_json need removed
      # TODO potentially remove this case, should be covered by sanitize_hash
      safe_environment.delete_if { |k,v| k =~ /rack/ || k =~ /action_controller/ || k == "_" }
      # needed to add a filter for the hash for "_", causing invalid xml.
      sanitize_hash(safe_environment)
    end

    def safe_session(session)
      result = {}
      session.instance_variables.each do |v|
        next if v =~ /cgi/ || v =~ /db/ || v =~ /env/
        var = v.sub("@","") # remove prepended @'s
        result[var] = session.instance_variable_get(v)
      end
      sanitize_hash(result)
    end

    private

    # This (ironic) method sanitizes a hash by removing un-json-able objects from the passed in hash.
    #   needed as active_support's fails in some cases with a cyclical reference error.
    def sanitize_hash(hash)
      return {} if hash.nil?
      Hash.from_xml(hash.to_xml)['hash']
    end
  end
end