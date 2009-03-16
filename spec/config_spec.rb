require File.dirname(__FILE__) + '/spec_helper'


describe Exceptional::Config do
  
  before(:all) do
    config = Exceptional::Config

    def config.reset_state
      @api_key = nil
      @ssl_enabled = nil
      @log_level = nil
      @enabled = nil
      @remote_port = nil
      @remote_host = nil
      @applicaton_root = nil
    end
  end

  after(:each) do
    Exceptional::Config.reset_state
  end
  
  describe "default configuration" do
    it "should use port 80 by default if ssl not enabled" do
      Exceptional::Config.ssl_enabled?.should be_false
      Exceptional::Config.remote_port.should == 80
    end

    it "should use port 443 if ssl enabled" do
      Exceptional::Config.ssl_enabled= true
      Exceptional::Config.remote_port.should == 443
      Exceptional::Config.ssl_enabled= false
    end

    it "should use log level of info by default" do
      Exceptional::Config.log_level.should == "info"
    end

    it "should not be enabled by default" do
      Exceptional::Config.enabled?.should be_false
    end

    it "should overwrite default host" do
      Exceptional::Config.remote_host.should == "getexceptional.com"
      Exceptional::Config.remote_host = "localhost"
      Exceptional::Config.remote_host.should == "localhost"
    end

    it "should overwrite default port" do
      Exceptional::Config.remote_port.should == 80

      Exceptional::Config.remote_port = 3000
      Exceptional::Config.remote_port.should == 3000
      Exceptional::Config.remote_port = nil
    end
    
    it "api_key should by default be in-valid" do
      Exceptional::Config.valid_api_key?.should be_false
    end
    
  end

  describe "load config" do

    it "error during config file loading raises configuration exception" do
      File.should_receive(:open).once.and_raise(IOError)

      config_file = File.expand_path("exceptional.yml")
      lambda{Exceptional::Config.load_config(config_file, "development", File.dirname(__FILE__))}.should raise_error(Exceptional::Config::ConfigurationException)
    end

    it "is enabled for production environment" do
      Exceptional::Config.enabled?.should be_false

      config_file = File.join(File.dirname(__FILE__),"../exceptional.yml")
      Exceptional::Config.load_config config_file, "production", File.dirname(__FILE__)
      Exceptional::Config.enabled?.should be_true
    end

    it "is enabled by default for production and staging environments" do
      Exceptional::Config.enabled?.should be_false

      config_file = File.join(File.dirname(__FILE__),"../exceptional.yml")

      Exceptional::Config.load_config config_file, "production", File.dirname(__FILE__)
      Exceptional::Config.enabled?.should be_true

      Exceptional::Config.reset_state
      Exceptional::Config.enabled?.should be_false

      config_file = File.join(File.dirname(__FILE__),"../exceptional.yml")
      Exceptional::Config.load_config config_file, "staging", File.dirname(__FILE__)
      Exceptional::Config.enabled?.should be_true
    end

    it "is disabled by default for development & test environments" do
      Exceptional::Config.enabled?.should be_false

      config_file = File.join(File.dirname(__FILE__),"../exceptional.yml")
      Exceptional::Config.load_config config_file, "development", File.dirname(__FILE__)
      Exceptional::Config.enabled?.should be_false

      Exceptional::Config.reset_state
      Exceptional::Config.enabled?.should be_false

      config_file = File.join(File.dirname(__FILE__),"../exceptional.yml")
      Exceptional::Config.load_config config_file, "test", File.dirname(__FILE__)
      Exceptional::Config.enabled?.should be_false
    end            
  end
end
