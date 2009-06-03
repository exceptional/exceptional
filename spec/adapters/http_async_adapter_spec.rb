require File.dirname(__FILE__) + '/../spec_helper'


describe Exceptional::Adapters::HttpAsyncAdapter do

  before(:all) do
    def Exceptional.reset_adapter
      @adapter = nil
    end
  end

  before(:each) do
    Exceptional.reset_adapter
    Exceptional.adapter_name = "HttpAsyncAdapter"

    Exceptional.stub!(:to_stderr) # Don't print error when testing
    Exceptional.stub!(:log!) # Don't even attempt to log
    Exceptional.stub!(:to_log)    
  end

  after(:all) do
    Exceptional.reset_adapter
  end

  TEST_API_KEY = "TEST_API_KEY" if !defined? TEST_API_KEY

  describe "sending data " do

    it "should return response body if successful" do

      Exceptional.api_key = TEST_API_KEY
      Exceptional.api_key_validated?.should be_false

      Exceptional.should_receive(:api_key_validated?).once.and_return(true)

      Thread.should_receive(:new).once
      Exceptional.post_exception("data")
    end

    it "should raise error of error instantiating thread" do

      Exceptional.api_key = TEST_API_KEY
      Exceptional.api_key_validated?.should be_false

      Exceptional.should_receive(:api_key_validated?).once.and_return(true)

      Thread.should_receive(:new).and_raise(IOError)

      lambda{Exceptional.post_exception("data")}.should raise_error(Exceptional::Adapters::HttpAsyncAdapterException)
    end
  end
end