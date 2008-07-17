module Exceptional::Agent
    
  # In teh background sending yer excepshuns
  class Worker
    
    attr_reader :log
    
    def initialize(log = Logger.new(STDERR))
      @exceptions = []
      @mutex = Mutex.new
      @log = log
      @log.info "Started worker."
    end
    
    def add_exception(data)
      @mutex.synchronize do 
        @exceptions << data
      end
    end
      
    def run
      while(true) do
        send_any_exception_data
      end
    end    
    
    private 
    
    def exception_to_send
      @mutex.synchronize do
        return @exceptions.shift
      end
    end
    
    
    def send_any_exception_data
      if @exceptions.empty?
        sleep 42
        return
      end
      
      data = exception_to_send
      
      begin
       Exceptional::Agent.instance.send_data(data)
      rescue Exception => e
       @log.debug "Error sending exception data: #{e}" 
       @log.debug e.backtrace.join("\n")
      end
    end
    
  end
end