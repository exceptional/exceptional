require File.dirname(__FILE__) + '/../spec_helper'


describe Exceptional::Adapters::FileAdapter do

  before(:all) do
    def Exceptional.reset_adapter
      @adapter = nil
    end
  end

  before(:each) do
    Exceptional.reset_adapter
    Exceptional.adapter_name = "FileAdapter"

  Exceptional.stub!(:to_stderr) # Don't print error when testing
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

      File.should_receive(:open).once
      FileTest.should_receive(:exists?).and_return(true)

      Exceptional.post_exception("data").should == true
    end
    
    it "should raise error if sending is unsuccessful" do

      Exceptional.api_key = TEST_API_KEY
      Exceptional.api_key_validated?.should be_false

      Exceptional.should_receive(:api_key_validated?).once.and_return(true)

      File.should_receive(:open).once.and_raise(IOError)

      lambda{Exceptional.post_exception("data")}.should raise_error(Exceptional::Adapters::FileAdapterException)
    end
  end
  
  describe "bootstrapping " do

    it "should raise error if configured work_dir is invalid" do

      adapter = Exceptional::Adapters::FileAdapter.new
      
      FileTest.should_receive(:exists?).twice.and_return(false)

      lambda{adapter.bootstrap}.should raise_error(Exceptional::Adapters::FileAdapterException)
    end
  end
end
