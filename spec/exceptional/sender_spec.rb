require File.dirname(__FILE__) + '/spec_helper'
require 'zlib'
require 'digest/md5'

describe Exceptional::Sender do
  before :each do
    Exceptional::Config.reset
    Exceptional::Config.api_key = 'abc123'
  end

  it "calls remote with api_key, protocol_version and json" do
    expected_url = "/api/errors?api_key=abc123&protocol_version=#{Exceptional::PROTOCOL_VERSION}"
    expected_data = mock('data',:uniqueness_hash => nil, :to_json => '123')
    Exceptional::Sender.should_receive(:call_remote).with(expected_url, Zlib::Deflate.deflate(expected_data.to_json,Zlib::BEST_SPEED))
    Exceptional::Sender.error(expected_data)
  end

  it "adds hash of backtrace as paramater if it is present" do
    expected_url = "/api/errors?api_key=abc123&protocol_version=#{Exceptional::PROTOCOL_VERSION}&hash=blah"
    expected_data = mock('data',:uniqueness_hash => 'blah', :to_json => '123')
    Exceptional::Sender.should_receive(:call_remote).with(expected_url, Zlib::Deflate.deflate(expected_data.to_json,Zlib::BEST_SPEED))
    Exceptional::Sender.error(expected_data)
  end

  it "calls remote for startup" do
    expected_url = "/api/announcements?api_key=abc123&protocol_version=#{Exceptional::PROTOCOL_VERSION}"
    startup_data = mock('data',:to_json => '123')
    Exceptional::Sender.should_receive(:call_remote).with(expected_url, Zlib::Deflate.deflate(startup_data.to_json,Zlib::BEST_SPEED))
    Exceptional::Sender.startup_announce(startup_data)
  end

  it "should respect custom logging instructions" do
    exceptions = []
    Exceptional::Config.tap do |config|
      config.stub(:send_to).and_return('log')
      config.log_printer = lambda { |exception_data| exceptions << exception_data }
    end
    expected_data = { :test_data => true }
    exceptions.should == []
    Exceptional::Sender.error(expected_data)
    exceptions.should == [expected_data]
    Exceptional::Sender.error(expected_data)
    exceptions.should == [expected_data, expected_data]
  end
end
