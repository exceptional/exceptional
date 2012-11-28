require 'digest/md5'

module Exceptional
  class ApplicationEnvironment
    def self.to_hash(framework)
      {
        'client' => {
          'name' => Exceptional::CLIENT_NAME,
          'version' => Exceptional::VERSION,
          'protocol_version' => Exceptional::PROTOCOL_VERSION
        },
        'application_environment' => {
          'environment' => environment,
          'env' => extract_environment(ENV),
          'host' => get_hostname,
          'run_as_user' => get_username,
          'application_root_directory' => (application_root.to_s.respond_to?(:force_encoding) ? application_root.to_s.force_encoding("UTF-8") : application_root),
          'language' => 'ruby',
          'language_version' => language_version_string,
          'framework' => framework,
          'libraries_loaded' => libraries_loaded
        }
      }
    end

    def self.environment
      Config.application_environment
    end

    def self.application_root
      Config.application_root
    end

    def self.extract_environment(env)
      env.reject do |k, v|
        is_http_header = (k =~ /^HTTP_/)
        is_filtered = Exceptional::ENVIRONMENT_FILTER.include?(k)
        matches_whitelist = Exceptional::ENVIRONMENT_WHITELIST.any?{|whitelist_filter| whitelist_filter.is_a?(Regexp) ? k =~ whitelist_filter : k.eql?(whitelist_filter)}
        is_http_header || is_filtered || !matches_whitelist
      end
    end

    def self.get_hostname
      require 'socket' unless defined?(Socket)
      Socket.gethostname
    rescue
      'UNKNOWN'
    end

    def self.language_version_string
      "#{RUBY_VERSION rescue '?.?.?'} p#{RUBY_PATCHLEVEL rescue '???'} #{RUBY_RELEASE_DATE rescue '????-??-??'} #{RUBY_PLATFORM rescue '????'}"
    end

    def self.get_username
      ENV['LOGNAME'] || ENV['USER'] || ENV['USERNAME'] || ENV['APACHE_RUN_USER'] || 'UNKNOWN'
    end

    def self.libraries_loaded
      begin
        return Hash[*Gem.loaded_specs.map{|name, gem_specification| [name, gem_specification.version.to_s]}.flatten]
      rescue
      end
      {}
    end
  end
end