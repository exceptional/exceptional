require 'yaml'

module Exceptional
  class Config
    class ConfigurationException < StandardError; end

    class << self
      DEFAULTS = {
        :ssl => false,
        :remote_host_http => 'plugin.getexceptional.com',
        :http_open_timeout => 2,
        :http_read_timeout => 4,
        :disabled_by_default => %w(development test)
      }

      attr_accessor :api_key, :enabled
      attr_accessor :http_proxy_host, :http_proxy_port, :http_proxy_username, :http_proxy_password
      attr_writer :ssl

      def load(config_file=nil)
        if (config_file && File.file?(config_file))
          begin
            config = YAML::load_file(config_file)
            env_config = config[application_environment] || {}
            @api_key = config['api-key'] || env_config['api-key']

            @http_proxy_host = config['http-proxy-host']
            @http_proxy_port = config['http-proxy-port']
            @http_proxy_username = config['http-proxy-username']
            @http_proxy_password = config['http-proxy-password']
            @http_open_timeout = config['http-open-timeout']
            @http_read_timeout = config['http-read-timeout'] 

            @ssl = config['ssl'] || env_config['ssl']
            @enabled = env_config['enabled']
            @remote_port = config['remote-port'].to_i unless config['remote-port'].nil?
            @remote_host = config['remote-host'] unless config['remote-host'].nil?
          rescue Exception => e
            raise ConfigurationException.new("Unable to load configuration #{config_file} for environment #{application_environment} : #{e.message}")
          end
        end
      end

      def api_key
        return @api_key unless @api_key.nil?
        @api_key ||= ENV['EXCEPTIONAL_API_KEY'] unless ENV['EXCEPTIONAL_API_KEY'].nil?
      end

      def application_environment
        ENV['RACK_ENV'] || ENV['RAILS_ENV']|| 'development'
      end

      def should_send_to_api?
        return @enabled unless @enabled.nil?
        @enabled = !(DEFAULTS[:disabled_by_default].include?(application_environment))
      end

      def application_root
        defined?(RAILS_ROOT) ? RAILS_ROOT : Dir.pwd
      end

      def ssl?
        @ssl ||= DEFAULTS[:ssl]
      end

      def remote_host
        @remote_host ||= DEFAULTS[:remote_host_http]
      end

      def remote_port
        @remote_port ||= ssl? ? 443 : 80
      end

      def reset
        @enabled = @ssl = @remote_host = @remote_port = @api_key = nil
      end

      def http_open_timeout
        @http_open_timeout ||= DEFAULTS[:http_open_timeout]
      end

      def http_read_timeout
        @http_read_timeout ||= DEFAULTS[:http_read_timeout]
      end
    end
  end
end