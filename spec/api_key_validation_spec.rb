require File.dirname(__FILE__) + '/spec_helper'
require 'date'

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
      @api_key_validated = false
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

    it "should be api_key_validated? if API authentication successful" do 
      Exceptional.api_key = TEST_API_KEY

      Exceptional.api_key_validated?.should be_false
      Exceptional.should_receive(:http_call_remote, {:method => "api_key_validate", :data => ""}).once.and_return("true")
      Exceptional.should_receive(:create_auth_file).and_return(true)
      
      Exceptional.api_key_validate.should be_true
      Exceptional.api_key_validated?.should be_true
      
    end

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

    it "with no API Key set throws Configuration Exception" do
      Exceptional.api_key_validated?.should be_false

      lambda {Exceptional.api_key_validate}.should raise_error(Exceptional::Config::ConfigurationException)
    end
  end
end