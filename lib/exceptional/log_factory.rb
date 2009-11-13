require 'logger'

module Exceptional
  class LogFactory
    def self.logger
      @logger ||= create_logger_with_fallback
    end

    private
    def self.create_logger_with_fallback
      begin
        log_dir = File.join(Config.application_root, 'log')
        Dir.mkdir(log_dir) unless File.directory?(log_dir)
        log_path = File.join(log_dir, "/exceptional.log")
        log = Logger.new(log_path)
        log.level = Logger::INFO
        def log.format_message(severity, timestamp, progname, msg)
          "[#{severity.upcase}] (#{[Kernel.caller[2].split('/').last]}) #{timestamp.utc.to_s} - #{msg2str(msg).gsub(/\n/, '').lstrip}\n"
        end
        def log.msg2str(msg)
          case msg
            when ::String
              msg
            when ::Exception
              "#{ msg.message } (#{ msg.class }): " <<
                (msg.backtrace || []).join(" | ")
            else
              msg.inspect
          end
        end
        log
      rescue
        return Rails.logger if defined?(Rails) && defined?(Rails.logger)
        return RAILS_DEFAULT_LOGGER if defined?(RAILS_DEFAULT_LOGGER)
        return Logger.new(STDERR)
      end
    end
  end
end