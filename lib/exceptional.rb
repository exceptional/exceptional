$:.unshift File.dirname(__FILE__)
require 'zlib'
require 'cgi'
require 'net/http'
require 'logger'
require 'yaml'
require 'json' unless defined? Rails

require 'exceptional/exception_data'
require 'exceptional/version'

module Exceptional
  class LicenseException < StandardError; end
  class ConfigurationException < StandardError; end
  
  ::PROTOCOL_VERSION = 3
  # Defaults for configuration variables
  ::REMOTE_HOST = "getexceptional.com"
  ::REMOTE_PORT = 80
  ::REMOTE_SSL_PORT = 443
  ::SSL = false
  ::LOG_LEVEL = 'info'
  ::LOG_PATH = nil
  
  class << self
    attr_accessor :api_key, :log, :log_path, :environment, :application_root
    attr_writer :remote_host, :remote_port, :ssl_enabled, :log_level
    
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
    
    # authenticate with getexceptional.com
    # returns true if the configured api_key is registered and can send data
    # otherwise false
    def authenticate
      begin    
        # TODO No data required to authenticate, send a nil string? hacky
        # TODO should retry if a http connection failed
        return @authenticated if @authenticated
        authenticated = call_remote(:authenticate, "")
        @authenticated = authenticated =~ /true/ ? true : false
      rescue 
        @authenticated = false
      ensure
        return @authenticated
      end
    end
    
    # post the given exception data to getexceptional.com
    def post(exception_data)
      hash = exception_data.to_hash
      if hash[:session]
        hash[:session].delete("initialization_options")
        hash[:session].delete("request")
      end
      call_remote(:errors, hash.to_json)
    end
    
    # given a regular ruby Exception class, will parse into an ExceptionData
    # object and post to getexceptional.com
    def catch(exception)
      exception_data = parse(exception)
      exception_data.controller_name = File.basename($0)
      post(exception_data)
    end
    
    def authenticated?
      @authenticated || false
    end
    
    # used with Rails, takes an exception, controller, request and parameters
    # creates an ExceptionData object
    # if Exceptional is running in :direct mode, will post to getexceptional.com
    def handle(exception, controller, request, params)
      log! "Handling #{exception.message}", 'info'
      begin
        e = parse(exception)
        # Additional data for Rails Exceptions
        e.framework = "rails"
        e.controller_name = controller.controller_name
        e.action_name = controller.action_name
        e.application_root = self.application_root
        e.occurred_at = Time.now.strftime("%Y%m%d %H:%M:%S %Z")
        e.environment = request.env.to_hash
        e.url = "#{request.protocol}#{request.host}#{request.request_uri}"
        e.environment = safe_environment(request)  
        e.session = safe_session(request.session)
        e.parameters = params.to_hash
        
        post(e)
      rescue Exception => exception
        log! "Error preparing exception data."
        log! exception.message
        log! exception.backtrace.join("\n"), 'debug'
      end
    end
    
    # TODO these configuration methods & defaults should have their own class
    def remote_host
      @remote_host || ::REMOTE_HOST
    end
    
    def remote_port
      @remote_port || default_port
    end
    
    def log_level
      @log_level || ::LOG_LEVEL
    end
    
    def default_port
      ssl_enabled? ? ::REMOTE_SSL_PORT : ::REMOTE_PORT  
    end
    
    def ssl_enabled?
      @ssl_enabled || ::SSL
    end
    
    def enabled?
      @enabled
    end
    
    def format_log_message(msg)
      "** [Exceptional] " + msg 
    end

    def to_stderr(msg)
      STDERR.puts format_log_message(msg)
    end
    
    def log!(msg, level = 'info')
      to_stderr msg
      to_log level, msg
    end
    
    def to_log(level, msg)
      log.send level, msg if log
    end
    
    def log_config_info
      to_log('debug', format_log_message("API Key: #{api_key}"))
      to_log('debug', format_log_message("Remote Host: #{remote_host}:#{remote_port}"))
      to_log('debug', format_log_message("Log level: #{log_level}"))
      to_log('debug', format_log_message("Log path: #{log_path}"))
    end
    
    def setup_log
      self.log_path = "#{Exceptional.application_root}/log/exceptional.log"
      
      log = Logger.new log_path
      log.level = Logger::INFO

      allowed_log_levels = ['debug', 'info', 'warn', 'error', 'fatal']
      if log_level && allowed_log_levels.include?(log_level)
        log.level = eval("Logger::#{log_level.upcase}")
      end

      self.log = log
    end
    
    def load_config(file)
      begin
        config = YAML::load(File.open(file))[self.environment]
        @api_key = config['api-key'] unless config['api-key'].nil?
        @ssl_enabled = config['ssl'] unless config['ssl'].nil?
        @log_level = config['log-level'] unless config['log-level'].nil?
        @enabled = config['enabled'] unless config['enabled'].nil?
        @remote_port = config['remote-port'].to_i unless config['remote-port'].nil?
        @remote_host = config['remote-host'] unless config['remote-host'].nil?
      rescue Exception => e
        raise ConfigurationException.new("Unable to load configuration file:#{file} for environment:#{environment}")
      end
    end
    
    protected 
    
    def valid_api_key?
      @api_key && @api_key.length == 40
    end

    def call_remote(method, data)
      if @api_key.nil?
        raise LicenseException.new("API Key must be configured") 
      end
      
      http = Net::HTTP.new(remote_host, remote_port) 
      http.use_ssl = true if ssl_enabled?
      uri = "/#{method.to_s}?&api_key=#{@api_key}&protocol_version=#{::PROTOCOL_VERSION}"
      headers = method.to_s == 'errors' ? { 'Content-Type' => 'application/x-gzip', 'Accept' => 'application/x-gzip' } : {}
      compressed_data = CGI::escape(Zlib::Deflate.deflate(data, Zlib::BEST_SPEED))
      response = http.start do |http|
        http.post(uri, compressed_data, headers) 
      end
      
      if response.kind_of? Net::HTTPSuccess
        return response.body
      else
        raise Exception.new("#{response.code}: #{response.message}")
      end 

    rescue Exception => e
      log! "Error contacting Exceptional: #{e}", 'info'
      log! e.backtrace.join("\n"), 'debug'
      raise e
    end

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
