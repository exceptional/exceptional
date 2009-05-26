require File.dirname(__FILE__) + '/spec_helper'


describe Exceptional::Bootstrap do


  describe "setup" do

    TEST_ENVIRONMENT= "development"

    it "should initialize the config and log" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)

      Exceptional.bootstrap(TEST_ENVIRONMENT, File.join(File.dirname(__FILE__),"config", "exceptional.yml"), File.dirname(__FILE__))
    end

    it "should api_key_validate if enabled" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)
      Exceptional.should_receive(:enabled?).and_return(true)
      Exceptional.should_receive(:api_key_validate).and_return(true)
      STDERR.should_not_receive(:puts) #Should be no errors to report

      Exceptional.bootstrap(TEST_ENVIRONMENT, File.join(File.dirname(__FILE__),"config", "exceptional.yml"), File.dirname(__FILE__))
    end

    it "should not api_key_validate if not enabled" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)
      Exceptional.should_receive(:enabled?).and_return(false)
      Exceptional.should_not_receive(:api_key_validate)
      STDERR.should_not_receive(:puts) # Will silently not enable itself


      Exceptional.bootstrap(TEST_ENVIRONMENT, File.join(File.dirname(__FILE__),"config", "exceptional.yml"), File.dirname(__FILE__))
    end

    it "should report to STDERR if authentication fails" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)
      Exceptional.should_receive(:enabled?).and_return(true)
      Exceptional.should_receive(:api_key_validate).and_return(false)
      STDERR.should_receive(:puts) #Should be no errors to report

      Exceptional.bootstrap(TEST_ENVIRONMENT, File.join(File.dirname(__FILE__),"config", "exceptional.yml"), File.dirname(__FILE__))
    end

    it "should report to STDERR if error during config initialization" do
      Exceptional.should_receive(:setup_config).and_raise(Exceptional::Config::ConfigurationException)
      Exceptional.should_not_receive(:setup_log)
      Exceptional.should_not_receive(:api_key_validate).and_return(false)
      STDERR.should_receive(:puts) #Should be no errors to report

      Exceptional.bootstrap(TEST_ENVIRONMENT, File.join(File.dirname(__FILE__),"config", "exceptional.yml"), File.dirname(__FILE__))
    end
    
    it "should raise ConfigurationException if bootstrap fails" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)
      Exceptional.should_receive(:enabled?).and_return(true)
      Exceptional.should_receive(:api_key_validate).and_return(true)
      mock_adapter = mock(Exceptional::Adapters::HttpAdapter)
      mock_adapter.should_receive(:bootstrap).and_return(false)
      Exceptional.should_receive(:adapter).and_return(mock_adapter)
      
      STDERR.should_receive(:puts) #Should report error

      Exceptional.bootstrap(TEST_ENVIRONMENT, File.join(File.dirname(__FILE__),"config", "exceptional.yml"), File.dirname(__FILE__))
    end
  end
end