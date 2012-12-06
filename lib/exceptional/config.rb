require 'yaml'
require 'erb'

module Exceptional
  class Config
    class ConfigurationException < StandardError;
    end

    class << self
      DEFAULTS = {
          :ssl => false,
          :remote_host_http => 'plugin.getexceptional.com',
          :http_open_timeout => 2,
          :http_read_timeout => 4,
          :disabled_by_default => %w(development test),
          :send_to => 'api'
      }

      attr_accessor :api_key, :enabled, :http_proxy_host, :http_proxy_port,
        :http_proxy_username, :http_proxy_password, :ignore_user_agents,
        :ignore_exceptions, :stdout_printer, :log_printer

      attr_writer :ssl

      def load(config_file=nil)

        @log_printer ||= lambda do |exception_data|
          Exceptional.logger.info "Exceptional error: #{exception_data.inspect}"
        end

        @stdout_printer ||= lambda do |exception_data|
          puts "Exceptional error: #{exception_data.inspect}"
        end

        if (config_file && File.file?(config_file))
          begin
            config = YAML.load(ERB.new(File.new(config_file).read).result)
            env_config = config[application_environment] || {}
            @api_key = config['api-key'] ||
                env_config['api-key'] ||
                ENV['EXCEPTIONAL_API_KEY']

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
            @ignored_agents = config['ignored-agents']
            @ignored_exceptions = config['ignored-exceptions']
            @send_to = env_config['send_to'] || DEFAULTS[:send_to]

            valid_send_to = %w(api log stdout)
            unless valid_send_to.include?(send_to)
              raise "the value of the send_to configuration entry must be one of #{valid_send_to}"
            end
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
        ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
      end

      def should_send_to_api?
        return @enabled unless @enabled.nil?
        @enabled = !(DEFAULTS[:disabled_by_default].include?(application_environment))
      end

      def application_root
        (defined?(Rails) && Rails.respond_to?(:root)) ? Rails.root : Dir.pwd
      end

      def ssl?
        @ssl ||= DEFAULTS[:ssl]
      end

      def send_to
        @send_to ||= DEFAULTS[:send_to]
      end
      
      def ignore_user_agents
        @ignore_user_agents ||= []
      end
      
      def ignore_exceptions
        @ignore_exceptions ||= []
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
