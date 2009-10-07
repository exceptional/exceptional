require 'rubygems'
begin
  require 'ginger'
rescue LoadError
  raise "cant load ginger"
end
gem 'rails'
require File.dirname(__FILE__) + '/../lib/exceptional' unless defined?(Exceptional)

require 'action_controller'
require 'action_controller/test_process'

def request(action = nil, method = :get, user_agent = nil, params = {})
  @request = ActionController::TestRequest.new
  @request.action = action ? action.to_s : ""

  if user_agent
    if @request.respond_to?(:user_agent=)
      @request.user_agent = user_agent
    else
      @request.env["HTTP_USER_AGENT"] = user_agent
    end
  end
  @request.query_parameters = @request.query_parameters.merge(params)
  @response = ActionController::TestResponse.new
  @controller.process(@request, @response)
end
