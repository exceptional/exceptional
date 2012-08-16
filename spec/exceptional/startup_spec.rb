require File.dirname(__FILE__) + '/../spec_helper'

describe Exceptional::Startup, 'announce_and_authenticate' do
  it "raise StartupException if api_key is nil" do
    Exceptional::Config.api_key = ''
    lambda { Exceptional::Startup.announce }.should raise_error(Exceptional::StartupException, /API Key/)
  end
  it "calls Remote announce by default" do
    Exceptional::Config.api_key = '123'
    Exceptional::Remote.should_receive(:startup_announce).with(hash_including({'client' => {'name' => Exceptional::CLIENT_NAME,
                                                                                            'version' => Exceptional::VERSION,
                                                                                            'protocol_version' => Exceptional::PROTOCOL_VERSION}}))
    Exceptional::Startup.announce
  end

  %w(log stdout).each do |send_to|
    it "does not call Remote announce for send_to == #{send_to}" do
      Exceptional::Config.stub(:send_to).and_return('stdout')
      Exceptional::Remote.should_not_receive(:startup_announce)
      Exceptional::Startup.announce
    end
  end
end