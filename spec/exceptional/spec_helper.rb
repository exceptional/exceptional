require "exceptional"
require "json"

ENV['RAILS_ENV'] = 'test'

def send_request(action = nil,params={})
  @request = ActionController::TestRequest.new
  @request.query_parameters = @request.query_parameters.merge(params)
  @request.stub!(:request_method).and_return('GET')
  @request.action = action ? action.to_s : ""
  @response = ActionController::TestResponse.new
  @controller.process(@request, @response)
end
