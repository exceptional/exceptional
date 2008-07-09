require 'net/https' 
require 'net/http'
require 'builder'

module Exceptional
  
  PROTOCOL_VERSION = 1
  REMOTE_HOST = "getexceptional.com"
  REMOTE_PORT = 80
  
  class Agent
    
    cattr_accessor :api_key
    
    
    # TODO make controller and request optional to handle errors in daemons
    def self.send_data(exception, controller, request)
      xml = prepare_xml(exception,controller,request)
      http = Net::HTTP.new(REMOTE_HOST, REMOTE_PORT.to_i) 
      uri = "/errors?&api_key=#{Exceptional::Agent.api_key}&protocol_version=#{PROTOCOL_VERSION}"
      headers = { 'Content-Type' => 'application/xml', 'Accept' => 'application/xml' }
      response = http.start do |http|
        http.post(uri, xml, headers) 
      end
    end
    
    protected
    
    def self.prepare_xml(exception,controller,request)
      xml = Builder::XmlMarkup.new
      xml.instruct! 
      xml.error do |e|
        e.api_key Exceptional::Agent.api_key
        e.controller_name controller.controller_name
        e.action_name controller.action_name
        e.backtrace exception.backtrace.join("\n")
        e.user_ip request.env["HTTP_X_FORWARDED_FOR"] || request.env["REMOTE_ADDR"]
        e.host_ip request.env["HTTP_HOST"]
        e.environment prepare_environment_to_send(request.env)
        e.session prepare_session_to_send(request.session)
        e.request prepare_request_to_send(request)
        e.occurred_at Time.now.to_s
        e.summary "#{controller.controller_name}##{controller.action_name} (#{exception.class}) #{exception.message.inspect}"
      end
      xml.target!
    end
    
    def self.prepare_environment_to_send(environment)
      env = ""
      environment.keys.sort.each do |key|
        env << "#{key}:, #{environment[key].to_s.strip}\n"
      end
      env
    end

    def self.prepare_request_to_send(request)
      req = ""
      req << "URL: #{request.protocol}#{request.env["HTTP_HOST"]}#{request.request_uri}\n"
      req << "Parameters: #{request.parameters.inspect}\n"
      req << "Rails root: #{RAILS_ROOT}"
      req
    end

    def self.prepare_session_to_send(session)
      ses = ""
      for variable in session.instance_variables
        next if variable =~ /^@db/
        ses << "#{variable}: #{session.instance_variable_get(variable)}\n"
      end
      ses
    end
  end
end
