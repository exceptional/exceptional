require 'rubygems'
begin
  require 'ginger'
rescue LoadError
  raise "cant load ginger"
end

gem 'rails'
require File.dirname(__FILE__) + '/../lib/exceptional' unless defined?(Exceptional)

ENV['RAILS_ENV'] = 'test'

require 'action_controller'
require 'action_controller/test_process'

def send_request(action = nil,params={})
  @request = ActionController::TestRequest.new
  @request.query_parameters = @request.query_parameters.merge(params)
  @request.stub!(:request_method).and_return('GET')
  @request.action = action ? action.to_s : ""
  @response = ActionController::TestResponse.new
  @controller.process(@request, @response)
end