require 'digest/md5'

module Exceptional
  class ControllerExceptionData < ExceptionData
    def initialize(exception, controller=nil, request=nil)
      super(exception)
      @request = request
      @controller = controller
    end

    def framework
      "rails"
    end

    def extra_stuff                                                                                               
      return {} if @request.nil?
      {
        'request' => {
          'url' => (@request.respond_to?(:url) ? @request.url : "#{@request.protocol}#{@request.host}#{@request.request_uri}"),
          'controller' => @controller.class.to_s,
          'action' => (@request.respond_to?(:parameters) ? @request.parameters['action'] : @request.params['action']),
          'parameters' => filter_parameters(@request.respond_to?(:parameters) ? @request.parameters : @request.params),
          'request_method' => @request.request_method.to_s,
          'remote_ip' => (@request.respond_to?(:remote_ip) ? @request.remote_ip : @request.ip),
          'headers' => extract_http_headers(@request.env),
          'session' => self.class.sanitize_session(@request)
        }
      }
    end

    def filter_hash(keys_to_filter, hash)
      keys_to_filter.map! {|x| x.to_s}
      if keys_to_filter.is_a?(Array) && !keys_to_filter.empty?
        hash.each do |key, value|
          if key_match?(key, keys_to_filter)
            hash[key] = "[FILTERED]"
          elsif value.respond_to?(:to_hash)
            filter_hash(keys_to_filter, hash[key])
          end
        end
      end
      hash
    end

    # Closer alignment to latest filtered_params:
    # https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/http/parameter_filter.rb
    # https://github.com/exceptional/exceptional/issues/20
    def key_match?(key, keys_to_filter)
      keys_to_filter.any? do |k| 
        regexp = k.is_a?(Regexp)? k : Regexp.new(k.to_s, true) 
        key =~ regexp
      end
    end

    def filter_parameters(hash)
      if @request.respond_to?(:env) && @request.env["action_dispatch.parameter_filter"]
        filter_hash(@request.env["action_dispatch.parameter_filter"], hash)
      elsif @controller.respond_to?(:filter_parameters)
        @controller.send(:filter_parameters, hash)
      else
        hash
      end
    end
  end
end
