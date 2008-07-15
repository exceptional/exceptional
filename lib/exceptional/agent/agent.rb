require 'net/https' 
require 'net/http'
require 'builder'

module Exceptional::Agent
  
  class << self
    def agent
      Exceptional::Agent::Agent.instance
    end
    
    alias instance agent
  end
  
  class Agent
    
    PROTOCOL_VERSION = 1
    REMOTE_HOST = "getexceptional.com"
    REMOTE_PORT = 80
    
    include Singleton
    attr_reader :api_key, :log
    
    # Helper methods
    include Munger
    include Interregator
    include Logging
    
    
    def start(config)
      if @started
        log! "Agent Started Already!"
        raise Exception.new("Duplicate attempt to start the Exceptional agent")
      end

      @config = config
     
      @local_port = determine_environment_and_port
      @local_host = determine_host
     
      setup_log
     
      @worker = Worker.new(@log)
      @started = true
     
      @api_key = config['api-key']
     
      @use_ssl = config['ssl'] || false
      default_port = @use_ssl ? 443 : 80
  
      unless @api_key && @api_key.length == 40
        log! "No API key found.  Please insert your API key into config/exceptional.yml"
        return
      end
          
      @worker_thread = Thread.new do 
        run_worker
      end
      
      log! "API key: " + @api_key
      log! "Mongrel (port): " + @local_port.to_s
      log! "Exceptional plugin loaded"
    end
    
    def queue_to_send(exception, controller, request)
      xml = prepare_xml(exception,controller,request)
      @worker.add_exception(xml)
    end
    # TODO make controller and request optional to handle errors in daemons
    
    def send_data(data)
      http = Net::HTTP.new(REMOTE_HOST, REMOTE_PORT.to_i) 
      uri = "/errors?&api_key=#{@api_key}&protocol_version=#{PROTOCOL_VERSION}"
      headers = { 'Content-Type' => 'application/xml', 'Accept' => 'application/xml' }
      response = http.start do |http|
        http.post(uri, data, headers) 
      end
    end
    
    protected
    
    def setup_log
      log_file = "#{RAILS_ROOT}/log/exceptional."
      log_file += @local_port ? "#{@local_port}.log" : "log"
      
      @log = Logger.new log_file
      @log.level = Logger::INFO
            
      log! "Agent Initialized: pid = #{$$}"
      to_stderr "Agent Log is found in #{log_file}"
      log.info "Runtime environment: #{@environment.to_s.titleize}"  
    end
    
    def run_worker
      #return unless should_run?
      
      #until @connected
      #  should_retry = connect
      #  return unless should_retry
      #end
          
      @worker.run
    end
    
    
    # Attempt to connect to the exceptional server
    def connect
      @connection_retry_period ||= 5
      @connection_attempts ||= 0

      sleep @connect_retry_period.to_i

      @agent_id = invoke_remote :launch, @local_host, @local_port, determine_home_directory, $$, @launch_time.to_f

      log! "Connected to Exceptional Service at #{@remote_host}:#{@remote_port}."
      log.debug "Agent ID = #{@agent_id}."

      # Ask the server for permission to send transaction samples.  determined by suvbscription license.
      @connection_allowed = invoke_remote :should_collect_samples, @agent_id

      @connected = true
      return true
      
    rescue LicenseException => e
      log! e.message, :error
      log! "Invalid API key, signup for an account at getexceptional.com"
      log! "Turning Exceptional Agent off."
      return false

    rescue Exception => e
      log.error "Error attempting to connect to Exceptional Service at #{@remote_host}:#{@remote_port}"
      log.error e.message
      log.debug e.backtrace.join("\n")

      @connect_attempts += 1
      if @connect_attempts > 20
        @connect_retry_period, period_msg = 10.minutes, "10 minutes"
      elsif @connect_attempts > 10
        @connect_retry_period, period_msg = 1.minutes, "1 minute"
      elsif @connect_attempts > 5
        @connect_retry_period, period_msg = 30, nil
      else
        @connect_retry_period, period_msg = 5, nil
      end

      log.info "Will re-attempt in #{period_msg}" if period_msg
      return true
    end
    
    # Ping the exceptional server 
    def disconnect
      
    end
    
    # send the given message to STDERR as well as the agent log, so that it shows
    # up in the console.  This should be used for important informational messages at boot
    def log!(msg, level = :info)
      to_stderr msg
      log.send level, msg if log
    end
    
    def to_stderr(msg)
      # only log to stderr when we are running as a mongrel process, so it doesn't
      # muck with daemons and the like.
      unless @environment == :unknown
        STDERR.puts "** [Exceptional] " + msg 
      end
    end
end
