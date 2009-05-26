require 'yaml'

module Exceptional   #:nodoc:

#
# = Config 
#
#
#       api-key
#                Exceptional API Key (Required)
#
#       enabled
#                Whether to enable the Exceptional Plugin (Default = true)
#
#       ssl
#                To use SSL to communicate with getexceptional.com (Default = false)
#
#       log-level
#                Log Level for RAILS_ROOT/log/exceptional.log (Default 'info')
#
#       send-user-data
#                Whether to publish current_user data to the Exceptional Server (Default = false)
#
#       adapter
#                Exception data publish adapter (Default = 'HttpAdapter') - (see adapters section below)
#
#       remote_host
#                Exceptional Server host (Default = "getexceptional.com")
#
#       remote_port
#                Exceptioal Server port (Default = "80")
#
#       work_dir
#                Path to directory used for temporary file creaton (File Adapter) (Default = RAILS_ROOT/tmp/exceptional)
#
    
module Config
    DEFAULT_ENABLED = false
    DEFAULT_HOST = "getexceptional.com"
    DEFAULT_PORT = 80
    DEFAULT_SSL_PORT = 443
    DEFAULT_SSL_ENABLED = false
    DEFAULT_LOG_LEVEL = 'info'
    DEFAULT_LOG_PATH = nil
    DEFAULT_ADAPTER_NAME = "HttpAdapter"

    class ConfigurationException < StandardError  #:nodoc:
    end

    # Load exceptional.yml config from config_file
    def setup_config(environment, config_file, applicaton_root)
            
      begin
        config = YAML::load(File.open(config_file))[environment]
        @api_key = config['api-key'] unless config['api-key'].nil?
        @ssl_enabled = config['ssl'] unless config['ssl'].nil?
        @log_level = config['log-level'] unless config['log-level'].nil?
        @enabled = config['enabled'] unless config['enabled'].nil?
        @remote_port = config['remote-port'].to_i unless config['remote-port'].nil?
        @remote_host = config['remote-host'] unless config['remote-host'].nil?
        @adapter_name = config['adapter'] unless config['adapter'].nil?
        @work_dir = config['work_dir'] unless config['work_dir'].nil?
        @send_user_data = config['send-user-data'] unless config['send-user-data'].nil?

        @applicaton_root = applicaton_root

        log_config_info
      rescue Exception => e
        raise ConfigurationException.new("Unable to load configuration #{config_file} for environment #{environment} : #{e.message}")
      end
    end
    
    def api_key
      @api_key
    end

    def api_key=(key)
      @api_key = key
    end

    def application_root?
      @applicaton_root || @applicaton_root = (File.dirname(__FILE__) + '/../../../../..')
    end

    def remote_host?
      @remote_host || DEFAULT_HOST
    end
    
    def remote_host=(host)
      @remote_host = host
    end

    def remote_port?
      @remote_port || default_port?
    end
    
    def remote_port=(port)
      @remote_port = port
    end

    def log_level?
      @log_level || DEFAULT_LOG_LEVEL
    end

    def adapter_name?
      @adapter_name || DEFAULT_ADAPTER_NAME
    end
    
    def adapter_name=(adapter)
      @adapter_name = adapter
    end

    def work_dir?
      @work_dir || @work_dir = File.expand_path(File.join(application_root?, "/log/exceptional"))
    end

    def ssl_enabled?
      @ssl_enabled || DEFAULT_SSL_ENABLED
    end
    
    def ssl_enabled=(ssl)
      @ssl_enabled = ssl
    end

    def enabled?
      @enabled || DEFAULT_ENABLED
    end

    def valid_api_key?
      @api_key && @api_key.length == 40 ? true : false
    end

    def send_user_data?
      @send_user_data || false
    end

    protected
    
    def default_port?
      ssl_enabled? ? DEFAULT_SSL_PORT : DEFAULT_PORT
    end

    def log_config_info
      Exceptional.to_log("API Key: #{api_key}", 'debug')
      Exceptional.to_log("Remote Host: #{remote_host?}:#{remote_port?}", 'debug')
      Exceptional.to_log("Log level: #{log_level?}", 'debug')
    end
  end
end