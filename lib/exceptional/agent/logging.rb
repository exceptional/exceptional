module Exceptional::Agent
  
  # Methods for logging stuff
  module Logging
    
    # Log to STDERR and separate agent log
    def log!(msg, level = :info)
      to_stderr msg
      log.send level, msg if log
    end
    
    def to_stderr(msg)
      STDERR.puts "** [Exceptional] " + msg 
    end
    
    def setup_log
      log_file = "#{RAILS_ROOT}/log/exceptional."
      log_file += @local_port ? "#{@local_port}.log" : "log"
      
      @log = Logger.new log_file
      @log.level = Logger::INFO
      
      allowed_log_levels = ['debug', 'info', 'warn', 'error', 'fatal']
      if @config['log-level'] && allowed_log_levels.include?(@config['log-level'])
        @log.level = "Logger::#{@config['log-level'].upcase}".constantize
      end
      
      log! "Agent Initialized, pid: #{$$}"
      to_stderr "Agent Log is found in #{log_file}"
      log.info "Runtime environment: #{@environment.to_s.titleize}"  
    end
  
  end
end