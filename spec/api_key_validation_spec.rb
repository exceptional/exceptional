require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::APIKeyValidation do
  
  TEST_API_KEY = "TEST_API_KEY"

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
      @authenticated = false
    end
  end

  after(:each) do
    Exceptional.reset_state
    Exceptional.reset_authentication
  end

  describe "authentication" do

    it "should not be authenticated if API authentication unsuccessful" do
      Exceptional.api_key = TEST_API_KEY

      Exceptional.authenticated?.should be_false
      Exceptional.should_receive(:http_call_remote, {:method => "authenticate", :data => ""}).once.and_return("false")
      Exceptional.authenticate.should be_false
      Exceptional.authenticated?.should be_false
    end

    it "should not be authenticated if error during API authenticate" do
      Exceptional.api_key = TEST_API_KEY

      Exceptional.authenticated?.should be_false
      Exceptional.should_receive(:http_call_remote, {:method => "authenticate", :data => ""}).once.and_raise(IOError)

      Exceptional.authenticate.should be_false
      Exceptional.authenticated?.should be_false
    end

    it "should not re-authenticate subsequently if 1 successful " do
      Exceptional.api_key = TEST_API_KEY

      Exceptional.authenticated?.should be_false
      Exceptional.should_receive(:http_call_remote, {:method => "authenticate", :data => ""}).once.and_return("true")
      # If authentication is successful, authenticate called only once

      Exceptional.authenticate.should be_true
      Exceptional.authenticated?.should be_true

      Exceptional.authenticate.should be_true
      Exceptional.authenticated?.should be_true
    end

    it "with no API Key set throws Configuration Exception" do
      Exceptional.authenticated?.should be_false

      lambda {Exceptional.authenticate}.should raise_error(Exceptional::Config::ConfigurationException)
    end
  end
end