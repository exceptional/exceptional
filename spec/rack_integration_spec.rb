require File.dirname(__FILE__) + '/spec_helper'
require 'rack/mock'

class ExceptionalTestError < StandardError
end

describe Rack::Exceptional do
    
  before(:each) do 
    Exceptional::Config.should_receive(:load)
    @error = ExceptionalTestError.new
    @app = lambda { |env| raise @error, 'Whoops!' }
    @env = env = Rack::MockRequest.env_for("/foo")      
  end
  
  it 're-raises errors caught in the middleware' do       
    rr = Rack::Exceptional.new(@app)        
    Exceptional::Catcher.should_receive(:handle_with_rack)
    lambda { rr.call(@env)}.should raise_error(ExceptionalTestError)    
  end
end