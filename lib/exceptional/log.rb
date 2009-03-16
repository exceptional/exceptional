require 'logger'

module Exceptional
  module Log

    class <<self
      attr_accessor :log, :log_path, :log_level

      def setup
        begin
          log_dir = File.join(Config.application_root, "log")
          Dir.mkdir(log_dir) unless File.directory?(log_dir)
          self.log_path = File.join(log_dir, "/exceptional.log")

          log = Logger.new log_path
          log.level = Logger::INFO

          allowed_log_levels = ['debug', 'info', 'warn', 'error', 'fatal']
          if log_level && allowed_log_levels.include?(log_level)
            log.level = eval("Logger::#{log_level.upcase}")
          end

          self.log = log
        rescue Exception => e
          raise Config::ConfigurationException.new("Unable to create log file #{log_path}")
        end

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

    end
  end
end
