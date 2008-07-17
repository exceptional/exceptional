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
    
    include Munger
    include Interregator
    include Logging
    
    
    def start(config)
      unless RAILS_ENV == "production"
        to_stderr "Not running in production environment, disabling Exceptional"
        return
      end
      
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
        @worker.run
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
    
  end
end
