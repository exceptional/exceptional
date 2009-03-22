require File.dirname(__FILE__) + '/spec_helper'


describe Exceptional do

  describe "with no configuration" do
    before(:each) do
      Exceptional.stub!(:to_stderr) # Don't print error when testing
    end

    it "should raise a remoting exception if not authenticated" do
      exception_data = mock(Exceptional::ExceptionData,
      :message => "Something bad has happened",
      :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"],
      :class => Exception,
      :to_hash => { :message => "Something bad has happened" })

      Exceptional.api_key.should == nil
      Exceptional.should_receive(:authenticated?).once.and_return(false)

      lambda { Exceptional.post_exception(exception_data) }.should raise_error(Exceptional::Config::ConfigurationException)
    end
  end
  
  describe "setup" do
    
    TEST_ENVIRONMENT= "development"
    
    it "should initialize the config and log" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)
      
      Exceptional.setup(TEST_ENVIRONMENT, File.dirname(__FILE__))
    end
    
    it "should authenticate if enabled" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)
      Exceptional.should_receive(:enabled?).and_return(true)
      Exceptional.should_receive(:authenticate).and_return(true)
      STDERR.should_not_receive(:puts) #Should be no errors to report
      
      Exceptional.setup(TEST_ENVIRONMENT, File.dirname(__FILE__))
    end
    
    it "should not authenticate if not enabled" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)
      Exceptional.should_receive(:enabled?).and_return(false)
      Exceptional.should_not_receive(:authenticate)
      STDERR.should_not_receive(:puts) # Will silently not enable itself 

      
      Exceptional.setup(TEST_ENVIRONMENT, File.dirname(__FILE__))
    end
    
    it "should report to STDERR if authentication fails" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)
      Exceptional.should_receive(:enabled?).and_return(true)
      Exceptional.should_receive(:authenticate).and_return(false)
      STDERR.should_receive(:puts) #Should be no errors to report
      
      Exceptional.setup(TEST_ENVIRONMENT, File.dirname(__FILE__))
    end
    
    it "should report to STDERR if error during config initialization" do
      Exceptional.should_receive(:setup_config).and_raise(Exceptional::Config::ConfigurationException)
      Exceptional.should_not_receive(:setup_log)
      Exceptional.should_not_receive(:authenticate).and_return(false)
      STDERR.should_receive(:puts).twice() #Should be no errors to report
      
      Exceptional.setup(TEST_ENVIRONMENT, File.dirname(__FILE__))
    end
  end
end