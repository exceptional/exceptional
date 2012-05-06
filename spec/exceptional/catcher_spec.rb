require File.dirname(__FILE__) + '/../spec_helper'

describe Exceptional::Catcher do
  describe "when Exceptional reporting is on" do
    before do
      Exceptional::Config.stub(:should_send_to_api?).and_return(true)
    end
    it "handle_with_controller should create exception_data object and send json to the api" do
      exception = mock('exception')
      controller = mock('controller')
      request = mock('request')
      Exceptional::ControllerExceptionData.should_receive(:new).with(exception,controller,request).and_return(data = mock('exception_data'))
      Exceptional::Remote.should_receive(:error).with(data)
      Exceptional::Catcher.handle_with_controller(exception,controller,request)
    end
    # it "handle_with_rack should create exception_data object and send json to the api"
    # it "handle should create exception_data object and send json to the api"
  end

  describe "when Exceptional reporting is off" do
    before do
      Exceptional::Config.stub(:should_send_to_api?).and_return(false)
    end
    it "handle_with_controller should reraise the exception and not report it" do
      exception = mock('exception')
      controller = mock('controller')
      request = mock('request')
      Exceptional::ControllerExceptionData.should_not_receive(:new)
      Exceptional::Remote.should_not_receive(:error)
      expect{
        Exceptional::Catcher.handle_with_controller(exception,controller,request)
      }.to raise_error
    end
    # it "handle_with_rack should reraise the exception and not report it"
    # it "handle should reraise the exception and not report it"
  end
end