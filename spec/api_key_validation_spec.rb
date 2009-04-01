require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::APIKeyValidation do
  
  TEST_API_KEY = "TEST_API_KEY" unless defined?(TEST_API_KEY)

  before(:all) do
    def Exceptional.reset_state
      @api_key = nil
      @ssl_enabled = nil
      @log_level = nil
      @enabled = nil
      @remote_port = nil
      @remote_host = nil
      @applicaton_root = nil
    end

    def Exceptional.reset_authentication
      @api_key_validated = false
    end
  end

  after(:each) do
    Exceptional.reset_state
    Exceptional.reset_authentication
  end

  describe "authentication" do

    it "should not be api_key_validated if API authentication unsuccessful" do
      Exceptional.api_key = TEST_API_KEY

      Exceptional.api_key_validated?.should be_false
      Exceptional.should_receive(:http_call_remote, {:method => "api_key_validate", :data => ""}).once.and_return("false")
      Exceptional.api_key_validate.should be_false
      Exceptional.api_key_validated?.should be_false
    end

    it "should not be api_key_validated if error during API api_key_validate" do
      Exceptional.api_key = TEST_API_KEY

      Exceptional.api_key_validated?.should be_false
      Exceptional.should_receive(:http_call_remote, {:method => "api_key_validate", :data => ""}).once.and_raise(IOError)

      Exceptional.api_key_validate.should be_false
      Exceptional.api_key_validated?.should be_false
    end

    it "should not re-api_key_validate subsequently if 1 successful " do
      Exceptional.api_key = TEST_API_KEY

      Exceptional.api_key_validated?.should be_false
      Exceptional.should_receive(:http_call_remote, {:method => "api_key_validate", :data => ""}).once.and_return("true")
      # If authentication is successful, api_key_validate called only once

      Exceptional.api_key_validate.should be_true
      Exceptional.api_key_validated?.should be_true

      Exceptional.api_key_validate.should be_true
      Exceptional.api_key_validated?.should be_true
    end

    it "with no API Key set throws Configuration Exception" do
      Exceptional.api_key_validated?.should be_false

      lambda {Exceptional.api_key_validate}.should raise_error(Exceptional::Config::ConfigurationException)
    end
  end
end