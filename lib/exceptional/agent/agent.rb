require 'net/https' 
require 'net/http'
require 'builder'
require 'logger'
require 'singleton'

module Exceptional::Agent
  
  class << self
    def agent
      Exceptional::Agent::Agent.instance
    end
    
    alias instance agent
  end
  
  class Agent
    
    PROTOCOL_VERSION = 2
    REMOTE_HOST = "getexceptional.com"
    REMOTE_PORT = 80
    
    include Singleton
    attr_reader :api_key, :log
    
    include Munger
    include Interregator
    include Logging
    
    def start(config)
      return unless RAILS_ENV == "production"
      
      if @started
        log! "Agent started already!"
        raise Exception.new("Duplicate attempt to start the Exceptional agent.")
      end

      @config = config
           
      @param_filters = ['password']
      if config.has_key?('filter-parameters')
        @param_filters = @param_filters | config['filter-parameters'].split(',').map { |p| p.strip }
      end
      
      @local_port = determine_environment_and_port
      @local_host = determine_host
     
      setup_log
     
      @worker = Worker.new(@log)
      @started = true
      @start_time = Time.now 
      
      @api_key = config['api-key']
     
      @use_ssl = config['ssl'] || false
      default_port = @use_ssl ? 443 : 80
      @remote_port = config['port'] ? config['port'].to_i : default_port
      @remote_host = config['host'] || REMOTE_HOST
      
      unless @api_key && @api_key.length == 40
        log! "No API key found. Please insert your API key into config/exceptional.yml."
        return
      end
            
      @worker_thread = Thread.new do
        run_worker
      end
      
      log.debug "API key: " + @api_key
      log.debug "Mongrel (port): " + @local_port.to_s
      log.debug "Posting to: #{@remote_host}:#{@remote_port}"
      log! "Exceptional plugin loaded"
      
      at_exit do
        disconnect
        @worker_thread.terminate if @worker_thread
      end
    end
    
    def run_worker
      until @connected
        should_retry = connect
        return unless should_retry
      end 
      
      @worker.run
    end
    
    def connect
      @connection_attempts ||= 0
      @connection_retry_timeout ||= 5 # chill and let the web server boot
      sleep @connection_retry_timeout.to_i
      
      xml = prepare_connection_xml
      @agent_id = call_remote(:connect, xml)
      @connected = true
      log! "Connected to Exceptional."
      log.debug "Agent ID: #{@agent_id}."
      
    rescue Exception => e
      log.error "Unable to connect to Exceptional."
      log.error e.message
      log.debug e.backtrace.join("/n")
      
      @connection_attempts += 1
      if @connection_retry_timeout < 15.minutes
        @connection_retry_timeout += rand(60)
      else
        @connection_retry_timeout = 15.minutes
      end
      
      log.info "Re-attempting connection in #{@connection_retry_timeout} seconds."
      return true
    end
    
    def disconnect
      return unless @connected
      begin
        log.info "Disconnecting from Exceptional."
        call_remote :disconnect, prepare_disconnection_xml
        log.debug "ktnxbai!"
      rescue Exception => e
        log.warn "Error disconnecting from Exceptional."
        log.warn e
        log.debug e.backtrace.join("\n")
      end
    end
    
    def queue_to_send(exception, controller, request)
      xml = prepare_exception_xml(exception,controller,request)
      @worker.add_exception(xml)
    end
    
    def call_remote(method, xml)
      http = Net::HTTP.new(@remote_host, @remote_port) 
      uri = "/#{method.to_s}?&api_key=#{@api_key}&protocol_version=#{PROTOCOL_VERSION}"
      headers = { 'Content-Type' => 'application/xml', 'Accept' => 'application/xml' }
      response = http.start do |http|
        http.post(uri, xml, headers) 
      end
      
      if response.kind_of? Net::HTTPSuccess
        return response.body
      else
        raise Exception.new("#{response.code}: #{response.message}")
      end 

    rescue Exception => e
      log.error "Error contacting Exceptional: #{e}"
      log.debug e.backtrace.join("\n")
      raise e
    end
    
  end
end
