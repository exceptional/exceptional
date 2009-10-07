require File.dirname(__FILE__) + '/../spec_helper'
require 'zlib'
require 'cgi'

describe Exceptional::Remote do
  before :each do
    Exceptional::Config.reset
    Exceptional::Config.api_key = 'abc123'
  end

  it "calls remote with api_key, protocol_version and json" do
    expected_url = "/errors?api_key=abc123&protocol_version=#{Exceptional::PROTOCOL_VERSION}"
    expected_data = '"json"'
    Exceptional::Remote.should_receive(:call_remote).with(expected_url, expected_data)
    Exceptional::Remote.error('"json"')
  end
end