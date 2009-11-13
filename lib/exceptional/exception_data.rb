require 'digest/md5'

module Exceptional
  class ExceptionData
    def initialize(exception, controller=nil, request=nil)
      @exception = exception
      @request = request
      @controller = controller
    end

    def to_hash
      hash = ::Exceptional::ApplicationEnvironment.to_hash
      hash.merge!({
        'exception' => {
          'exception_class' => @exception.class.to_s,
          'message' => @exception.message,
          'backtrace' => @exception.backtrace,
          'occurred_at' => Time.now.strftime("%Y%m%d %H:%M:%S %Z")
        }
      })
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
            'session' => Exceptional::ExceptionData.sanitize_session(@request)
          }
        })
      end
      hash
    end

    def to_json
      to_hash.to_json
    end

    def uniqueness_hash
      return nil if @exception.backtrace.blank?
      Digest::MD5.hexdigest(@exception.backtrace.join)
    end

    def filter_paramaters(hash)
      if @controller.respond_to?(:filter_parameters)
        @controller.send(:filter_parameters, hash)
      else
        hash
      end
    end

    def extract_http_headers(env)
      headers = {}
      env.select{|k, v| k =~ /^HTTP_/}.each do |name, value|
        proper_name = name.sub(/^HTTP_/, '').split('_').map{|upper_case| upper_case.capitalize}.join('-')
        headers[proper_name] = value
      end
      unless headers['Cookie'].nil?
        headers['Cookie'] = headers['Cookie'].sub(/_session=\S+/, '_session=[FILTERED]')
      end
      headers
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

    def self.sanitize_session(request)
      session = request.session
      session_hash = {}
      session_hash['session_id'] = request.session_options ? request.session_options[:id] : nil
      session_hash['session_id'] ||= session.respond_to?(:session_id) ? session.session_id : session.instance_variable_get("@session_id")
      session_hash['data'] = session.respond_to?(:to_hash) ? session.to_hash : session.instance_variable_get("@data") || {}
      session_hash['session_id'] ||= session_hash['data'][:session_id]
      session_hash['data'].delete(:session_id)
      ExceptionData.sanitize_hash(session_hash)
    rescue
      {}
    end
  end
end