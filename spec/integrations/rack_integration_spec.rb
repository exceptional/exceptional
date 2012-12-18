require File.dirname(__FILE__) + '/spec_helper'
require 'rack/mock'

class ExceptionalTestError < StandardError
end


Wrapper = Rack::Builder.new do
  use Rack::Exceptional, "my_api_key"

  app = lambda do |env|
    raise ExceptionalTestError
  end

  run app
end.to_app


describe Rack::Exceptional do
    
  before(:each) do 
    @error = ExceptionalTestError.new
    @app = lambda { |env| raise @error, 'Whoops!' }
    @env = env = Rack::MockRequest.env_for("/foo")      
  end
  
  it 're-raises errors caught in the middleware' do       
    rr = Rack::Exceptional.new(@app)        
    Exceptional::Catcher.should_receive(:handle_with_rack)
    lambda { rr.call(@env)}.should raise_error(ExceptionalTestError)    
  end

  context "catching exceptions inside Rack apps" do
    before(:each) do
      @app = Wrapper
      @request = Rack::MockRequest.env_for("/exceptional")
    end

    it "catches exceptions raised in middleware" do
      Exceptional::Catcher.should_receive(:handle_with_rack)
      expect { @app.call(@request) }.to raise_exception(ExceptionalTestError)
    end
  end
end
