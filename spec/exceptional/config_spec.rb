require File.dirname(__FILE__) + '/../spec_helper'

describe Exceptional::Config, 'defaults' do
  before :each do
    Exceptional::Config.reset
  end
  it "have sensible defaults" do
    Exceptional::Config.ssl?.should == false
    Exceptional::Config.remote_host.should == 'plugin.getexceptional.com'
    Exceptional::Config.remote_port.should == 80
    Exceptional::Config.application_root.should == Dir.pwd
    Exceptional::Config.http_proxy_host.should be_nil
    Exceptional::Config.http_proxy_port.should be_nil
    Exceptional::Config.http_proxy_username.should be_nil
    Exceptional::Config.http_proxy_password.should be_nil
    Exceptional::Config.http_open_timeout.should == 2
    Exceptional::Config.http_read_timeout.should == 4
  end
  it "have correct defaults when ssl" do
    Exceptional::Config.ssl = true
    Exceptional::Config.remote_host.should == 'plugin.getexceptional.com'
    Exceptional::Config.remote_port.should == 443
  end
  it "be disabled based on environment by default" do
    %w(development test).each do |env|
      Exceptional::Config.stub!(:application_environment).and_return(env)
      Exceptional::Config.should_send_to_api?.should == false
    end    
  end
  it "be enabled based on environment by default" do
    %w(production staging).each do |env|
      Exceptional::Config.stub!(:application_environment).and_return(env)
      Exceptional::Config.should_send_to_api?.should == true
    end
  end
  context 'production environment' do
    before :each do
      Exceptional::Config.stub!(:application_environment).and_return('production')
    end
    it "allow a new simpler format for " do
      Exceptional::Config.load('spec/fixtures/exceptional.yml')
      Exceptional::Config.api_key.should == 'abc123'
      Exceptional::Config.ssl?.should == true
      Exceptional::Config.remote_host.should == 'example.com'
      Exceptional::Config.remote_port.should == 123
      Exceptional::Config.should_send_to_api?.should == true
      Exceptional::Config.http_proxy_host.should == 'annoying-proxy.example.com'
      Exceptional::Config.http_proxy_port.should == 1066
      Exceptional::Config.http_proxy_username.should == 'bob'
      Exceptional::Config.http_proxy_password.should == 'jack'
      Exceptional::Config.http_open_timeout.should == 5
      Exceptional::Config.http_read_timeout.should == 10
    end
    it "allow disable production environment" do      
      Exceptional::Config.load('spec/fixtures/exceptional_disabled.yml')
      Exceptional::Config.api_key.should == 'abc123'
      Exceptional::Config.should_send_to_api?.should == false
    end    
    it "allow olded format for exception.yml" do
      Exceptional::Config.load('spec/fixtures/exceptional_old.yml')
      Exceptional::Config.api_key.should == 'abc123'
      Exceptional::Config.ssl?.should == true
      Exceptional::Config.should_send_to_api?.should == true
    end
    it "load api_key from environment variable" do
      ENV.should_receive(:[]).with('EXCEPTIONAL_API_KEY').any_number_of_times.and_return('98765')
      Exceptional::Config.api_key.should == '98765'
    end
  end
end