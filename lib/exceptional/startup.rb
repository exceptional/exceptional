module Exceptional
  class StartupException < StandardError;
  end
  class Startup
    class << self
      def announce_and_authenticate
        if Config.api_key.blank?
          raise StartupException, 'API Key must be configured (/config/exceptional.yml)'
        end
        Remote.announce(Config.api_key, {:client_name => Exceptional::CLIENT_NAME, :client_version => Exceptional::VERSION,
                                         :protocol_version => Exceptional::PROTOCOL_VERSION,
                                         :language => 'ruby',
                                         :library_information => {
                                             :ruby_version => "#{RUBY_VERSION} #{RUBY_PLATFORM} #{RUBY_RELEASE_DATE}",
                                             :gems => gems_loaded
                                         }
        })
        true
      end

      def gems_loaded
        begin
          return Hash[*Gem.loaded_specs.map{|name, gem_specification| [name, gem_specification.version.to_s]}.flatten]
        rescue
        end
        {}
      end
    end
  end
end