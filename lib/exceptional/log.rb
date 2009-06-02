require 'logger'

module Exceptional
  module Log  #:nodoc:

    attr_reader :log
    
    def setup_log(log_dir, log_level = Logger::INFO)
      begin
        Dir.mkdir(log_dir) unless File.directory?(log_dir)

        
        log_path = File.join(log_dir, "/exceptional.log")
        log = Logger.new log_path
        
        log.level = log_level

        allowed_log_levels = ['debug', 'info', 'warn', 'error', 'fatal']
        if log_level && allowed_log_levels.include?(log_level)
          log.level = eval("Logger::#{log_level.upcase}")
          log.formatter = Logger::Formatter.new #Defaut Formatter will add timestamps to logs
        end

        @log = log
      rescue Exception => e
        raise Exceptional::Config::ConfigurationException.new("Unable to create log file #{log_path} #{e.message}")
      end
    end

    def log!(msg, level = 'info')
      to_log msg, level
      to_stderr msg
    end

    def to_stderr(msg)
      STDERR.puts format_log_message(msg)
    end

    def to_log(msg, level = 'info')
      @log.send level, msg if @log
    end

    private

    def format_log_message(msg)
      "** [Exceptional] " + msg
    end
  end
end