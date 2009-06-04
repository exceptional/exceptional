require File.dirname(__FILE__) + '/spec_helper'


describe Exceptional do

  describe "with no configuration" do
    before(:each) do
      Exceptional.stub!(:to_stderr) # Don't print error when testing
      Exceptional.stub!(:log!) # Don't even attempt to log
      Exceptional.stub!(:to_log)
      Exceptional.api_key = nil
    end

    it "should raise a remoting exception if not api_key_validated" do
      exception_data = mock(Exceptional::ExceptionData,
      :message => "Something bad has happened",
      :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"],
      :class => Exception,
      :to_hash => { :message => "Something bad has happened" })

      Exceptional.api_key.should == nil
      Exceptional.should_receive(:api_key_validated?).once.and_return(false)

      lambda { Exceptional.post_exception(exception_data) }.should raise_error(Exceptional::Config::ConfigurationException)
    end
  end
  
end