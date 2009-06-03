require File.dirname(__FILE__) + '/spec_helper'
require 'date'

describe Exceptional::APIKeyValidation do
  
  TEST_API_KEY = "TEST_API_KEY" unless defined?(TEST_API_KEY)

  before(:all) do
    def Exceptional.reset_state
      @api_key = nil
      @api_key_validated = nil
    end
  end
  
  before(:each) do
    Exceptional.stub!(:log!) # Don't even attempt to log
    Exceptional.stub!(:to_log)    
  end

  after(:each) do
    Exceptional.reset_state
  end

  describe "authentication" do
    
    it "should check for valid auth file if not authenticated yet" do
      Exceptional.should_receive(:valid_auth_file).once.and_return(false)
      
      Exceptional.api_key_validated?.should be_false
    end
    
    it "should authenticate if valid auth file exists" do
      Exceptional.should_receive(:valid_auth_file).once.and_return(true)
      Exceptional.api_key_validated?.should be_true
    end
    
    it "should be api_key_validated if API authentication successful" do 
      Exceptional.api_key = TEST_API_KEY

      Exceptional.api_key_validated?.should be_false
      
      Exceptional.should_receive(:http_call_remote, {:method => "api_key_validate", :data => ""}).once.and_return("true")
      Exceptional.should_receive(:create_auth_file).once.and_return(true)

      Exceptional.api_key_validate.should be_true      
      
      Exceptional.should_not_receive(:valid_auth_file)
      Exceptional.api_key_validated?.should be_true      
    end

    it "should not be api_key_validated if API authentication unsuccessful" do
      Exceptional.api_key = TEST_API_KEY

      Exceptional.api_key_validated?.should be_false
      
      Exceptional.should_receive(:http_call_remote, {:method => "api_key_validate", :data => ""}).once.and_return("false")
      Exceptional.should_not_receive(:create_auth_file)
      
      Exceptional.api_key_validate.should be_false
      Exceptional.api_key_validated?.should be_false
    end

    it "should not be api_key_validated if error during API api_key_validate" do
      Exceptional.api_key = TEST_API_KEY

      Exceptional.api_key_validated?.should be_false
      Exceptional.should_receive(:http_call_remote, {:method => "api_key_validate", :data => ""}).once.and_raise(IOError)
      Exceptional.should_not_receive(:create_auth_file)
      
      Exceptional.api_key_validate.should be_false
      Exceptional.api_key_validated?.should be_false
    end

    it "with no API Key set throws Configuration Exception" do
      Exceptional.api_key_validated?.should be_false

      lambda {Exceptional.api_key_validate}.should raise_error(Exceptional::Config::ConfigurationException)
    end
  end
  
  describe "valid auth file" do

    it "auth file less than a day old causes authentication to succeed" do
      Exceptional.should_receive(:tmp_dir).once.and_return("tmp/dir")
      FileTest.should_receive(:exists?).with("tmp/dir/.exceptional-authenticated").once.and_return(true)
      mock_file = mock(File)
      mock_file.should_receive(:mtime).twice.and_return(DateTime.now - 2)
      File.should_receive(:open).with("tmp/dir/.exceptional-authenticated").once.and_return(mock_file)
      
      Exceptional.api_key_validated?.should be_false
    end
        
    it "auth file less than a day old causes authentication to succeed" do
      Exceptional.should_receive(:tmp_dir).once.and_return("tmp/dir")
      FileTest.should_receive(:exists?).with("tmp/dir/.exceptional-authenticated").once.and_return(true)
      mock_file = mock(File)
      mock_file.should_receive(:mtime).twice.and_return(DateTime.now)
      File.should_receive(:open).with("tmp/dir/.exceptional-authenticated").once.and_return(mock_file)
      
      Exceptional.api_key_validated?.should be_true
    end
    
    it "should fail if auth file does not exist" do
      Exceptional.should_receive(:tmp_dir).once.and_return("tmp/dir")
      FileTest.should_receive(:exists?).with("tmp/dir/.exceptional-authenticated").once.and_return(false)
      
      Exceptional.api_key_validated?.should be_false
    end
  end
  
  describe "create auth file" do
    it "should create auth file on successful authentication" do    
      Exceptional.api_key = TEST_API_KEY
      
      Exceptional.should_receive(:valid_auth_file).once.and_return(false)
      Exceptional.should_receive(:http_call_remote).once.and_return("true")
      
      Exceptional.should_receive(:tmp_dir).once.and_return("tmp/dir")
      Exceptional.should_receive(:ensure_directory).once.and_return(true)
      
      mock_file = mock(File)
      File.should_receive(:open).with("tmp/dir/.exceptional-authenticated", "w").once.and_return(mock_file)
            
      Exceptional.api_key_validate.should be_true
      
    end
    
    it "should not create auth file on un-successful authentication" do    
      Exceptional.api_key = TEST_API_KEY
      
      Exceptional.should_receive(:valid_auth_file).once.and_return(false)
      Exceptional.should_receive(:http_call_remote).once.and_return("false")
      
      Exceptional.should_not_receive(:create_auth_file)
      
      Exceptional.api_key_validate.should be_false
      
    end
    
    it "should not authenticate if unable to create authentication file" do    
      Exceptional.api_key = TEST_API_KEY
      
      Exceptional.should_receive(:valid_auth_file).once.and_return(false)
      Exceptional.should_receive(:http_call_remote).once.and_return("true")
      
      Exceptional.should_receive(:tmp_dir).once.and_return("tmp/dir")
      Exceptional.should_receive(:ensure_directory).once.and_return(true)
      
      mock_file = mock(File)
      File.should_receive(:open).with("tmp/dir/.exceptional-authenticated", "w").once.and_raise(IOError.new)
            
      Exceptional.api_key_validate.should be_false
      
    end
  end    
end