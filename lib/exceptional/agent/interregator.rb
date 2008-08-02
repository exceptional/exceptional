module Exceptional::Agent
  
  # Methods for interregating the Rails environment  
  module Interregator
  
    def determine_host
      Socket.gethostname
    end
    
    def determine_environment_and_port
      port = nil
      @environment = :unknown
      # Webrick (The OPTIONS constant will be set if launched with script/server)
      port = OPTIONS.fetch :port, DEFAULT_PORT
      @environment = :webrick
      
    rescue NameError
      # Mongrel
      if defined? Mongrel::HttpServer
        ObjectSpace.each_object(Mongrel::HttpServer) do |mongrel|
          port = mongrel.port
          @environment = :mongrel
        end
      end
    rescue NameError
      log.info "Could not determine port."
    ensure
      return port
    end
    
  end
end