require 'digest/md5'

module Exceptional
  class ControllerDataExtractor
    def initialize(controller, request)
      @request = request
      @controller = controller
    end

    def controller
      "#{@controller.class}"
    end

    def url
      if @request.respond_to?(:url) 
        @request.url 
      else
        "#{@request.protocol}#{@request.host}#{@request.request_uri}"
      end
    end

    def action
      if @request.respond_to?(:parameters)
        @request.parameters['action'] 
      else
        @request.params['action']
      end
    end

    def parameters
      parameters = if @request.respond_to?(:parameters)
                     @request.parameters
                   else
                     @request.params
                   end

      filter_parameters(parameters)
    end

    def request_method
      "#{@request.request_method}"
    end

    def remote_ip
      if @request.respond_to?(:remote_ip) 
        @request.remote_ip 
      else 
        @request.ip
      end
    end

    def env
      @request.env
    end

    def request
      @request
    end

    private

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

  class ControllerExceptionData < ExceptionData
    def initialize(exception, controller=nil, request=nil)
      super(exception)
      @data = ControllerDataExtractor.new(controller, request) unless request.nil?
    end

    def framework
      "rails"
    end

    def extra_stuff
      return {} if @data.nil?
      {
        'request' =>
        {
            'url' => @data.url,
            'controller' => @data.controller,
            'action' => @data.action,
            'parameters' => @data.parameters,
            'request_method' => @data.request_method,
            'remote_ip' => @data.remote_ip,
            'headers' => extract_http_headers(@data.env),
            'session' => self.class.sanitize_session(@data.request)
        }
      }
    end
  end
end
