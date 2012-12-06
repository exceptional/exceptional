module Exceptional
  class StartupException < StandardError;
  end
  class Startup
    class << self
      def announce
        if Exceptional::Config.send_to == 'api'
          if Config.api_key.empty? || Config.api_key.nil?
            raise StartupException, 'API Key must be configured (/config/exceptional.yml)'
          end
          Sender.startup_announce(::Exceptional::ApplicationEnvironment.to_hash('rails'))
        end
      end
    end
  end
end
