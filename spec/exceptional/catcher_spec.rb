require File.dirname(__FILE__) + '/../spec_helper'

describe Exceptional::Catcher do
  it "should create exception_data object and send json to the api" do
    exception = mock('exception')
    controller = mock('controller')
    request = mock('request')
    Exceptional::ExceptionData.should_receive(:new).with(exception,controller,request).and_return(data = mock('exception_data'))
    Exceptional::Remote.should_receive(:error).with(data)
    Exceptional::Catcher.handle(exception,controller,request) 
  end
end