require File.dirname(__FILE__) + '/../spec_helper'

describe Exceptional::Startup, 'announce_and_authenticate' do
  it "raise StartupException if api_key is nil" do
    Exceptional::Config.api_key = ''
    lambda { Exceptional::Startup.announce_and_authenticate }.should raise_error(Exceptional::StartupException, /API Key/)
  end
  it "calls Remote announce" do
    Exceptional::Config.api_key = '123'
    Exceptional::Remote.should_receive(:announce).with('123', hash_including({:client_name => Exceptional::CLIENT_NAME,
                                                                              :client_version => Exceptional::VERSION,
                                                                              :protocol_version => Exceptional::PROTOCOL_VERSION,
                                                                              :language => 'ruby',
                                                                              :library_information => {
                                                                                  :ruby_version => anything(),
                                                                                  :gems => hash_including({'rails' => anything()})
                                                                              }
    }))
    Exceptional::Startup.announce_and_authenticate
  end
end