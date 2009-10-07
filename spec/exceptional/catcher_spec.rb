require File.dirname(__FILE__) + '/../spec_helper'

describe Exceptional::Catcher do
  it "should create exception_data object and send json to the api" do
    exception = mock('exception')
    controller = mock('controller')
    request = mock('request')
    params = mock('params')
    Exceptional::ExceptionData.should_receive(:new).with(exception,controller,request,params).and_return(mock('exception_data', :to_json =>'"json"'))
    Exceptional::Remote.should_receive(:error).with('"json"')
    Exceptional::Catcher.handle(exception,controller,request,params)
  end
end