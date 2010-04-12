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
          'parameters' => filter_paramaters(@request.respond_to?(:parameters) ? @request.parameters : @request.params),
          'request_method' => @request.request_method.to_s,
          'remote_ip' => (@request.respond_to?(:remote_ip) ? @request.remote_ip : @request.ip),
          'headers' => extract_http_headers(@request.env),
          'session' => self.class.sanitize_session(@request)
        }
      }
    end

    def filter_paramaters(hash)                                                                                       
      if @controller.respond_to?(:filter_parameters)
        @controller.send(:filter_parameters, hash)
      else
        hash
      end
    end
  end
end