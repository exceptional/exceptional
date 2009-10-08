module Exceptional
  class ExceptionData
    def initialize(exception, controller=nil, request=nil)
      @exception = exception
      @request = request
      @controller = controller
    end

    def to_hash
      hash = {
        'client' => {
          'name' => Exceptional::CLIENT_NAME,
          'version' => Exceptional::VERSION,
          'protocol_version' => Exceptional::PROTOCOL_VERSION
        },
        'exception' => {
          'exception_class' => @exception.class.to_s,
          'message' => @exception.message,
          'backtrace' => @exception.backtrace,
          'occurred_at' => Time.now.strftime("%Y%m%d %H:%M:%S %Z")
        },
        'application_environment' => {
          'environment' => RAILS_ENV,
          'env' => extract_environment(ENV),
          'host' => get_hostname,
          'run_as_user' => get_username,
          'application_root_directory' => Config.application_root,
          'language' => 'ruby',
          'language_version' => "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} #{RUBY_RELEASE_DATE} #{RUBY_PLATFORM}",
          'framework' => defined?(RAILS_ENV) ? "rails" : nil,
          'libraries_loaded' => libraries_loaded
        },

        }
      unless @request.nil?
        hash.merge!({
          'request' => {
            'url' => "#{@request.protocol}#{@request.host}#{@request.request_uri}",
            'controller' => @controller.class.to_s,
            'action' => @request.parameters['action'],
            'parameters' => filter_paramaters(@request.parameters),
            'request_method' => @request.request_method.to_s,
            'remote_ip' => @request.remote_ip,
            'headers' => extract_http_headers(@request.env),
            'session' => Exceptional::ExceptionData.sanitize_session(@request.session)
          }
        })
      end
      hash
    end

    def filter_paramaters(hash)
      if @controller.respond_to?(:filter_parameters)
        @controller.send(:filter_parameters, hash)
      else
        hash
      end
    end

    def extract_environment(env)
      env.reject{|k, v| k =~ /^HTTP_/}
    end

    def extract_http_headers(env)
      http_headers = {}
      env.select{|k, v| k =~ /^HTTP_/}.each do |name, value|
        proper_name = name.sub(/^HTTP_/, '').split('_').map{|upper_case| upper_case.capitalize}.join('-')
        http_headers[proper_name] = value
      end
      http_headers
    end

    def to_json
      to_hash.to_json
    end

    def get_hostname
      require 'socket' unless defined?(Socket)
      Socket.gethostname
    rescue
      'UNKNOWN'
    end

    def get_username
      ENV['LOGNAME'] || ENV['USER'] || ENV['USERNAME'] || 'UNKNOWN'
    end

    def libraries_loaded
      begin
        return Hash[*Gem.loaded_specs.map{|name, gem_specification| [name, gem_specification.version.to_s]}.flatten]
      rescue
      end
      {}
    end

    def self.sanitize_hash(hash)
      case hash
        when Hash
          hash.inject({}) do |result, (key, value)|
            result.update(key => sanitize_hash(value))
          end
        when Fixnum, Array, String, Bignum
          hash
        else
          hash.to_s
      end
    rescue
      {}
    end

    def self.sanitize_session(session)
      session_hash = {}
      session_hash['session_id'] = session.respond_to?(:session_id) ? session.session_id : session.instance_variable_get("@session_id")
      session_hash['data'] = session.respond_to?(:to_hash) ? session.to_hash : session.instance_variable_get("@data") || {}
      session_hash['session_id'] ||= session_hash['data'][:session_id] 
      session_hash['data'].delete(:session_id)
      ExceptionData.sanitize_hash(session_hash)
    rescue
      {}
    end
  end
end