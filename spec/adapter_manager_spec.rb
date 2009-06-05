require File.dirname(__FILE__) + '/spec_helper'


describe Exceptional::AdapterManager do

  before(:each) do
    Exceptional.stub!(:log!) # Don't even attempt to log
    Exceptional.stub!(:to_log)
  end

  after(:each) do
    def Exceptional.reset_state
      @adapter = nil
    end

    Exceptional.reset_state
  end

  describe "instantiating valid adapter" do
    it "should instantiate HTTPAdapter adapter" do
      Exceptional.should_receive(:adapter_name).once.and_return("HttpAdapter")
      Exceptional.should_receive(:api_key_validated?).once.and_return(true)
      adapter_mock = mock(Exceptional::Adapters::HttpAdapter)
      adapter_mock.should_receive(:publish_exception)
      Exceptional::Adapters::HttpAdapter.should_receive(:new).and_return(adapter_mock)
      Exceptional.post_exception(nil)
    end

    it "should instantiate FileAdapter adapter" do
      Exceptional.should_receive(:adapter_name).once.and_return("FileAdapter")
      Exceptional.should_receive(:api_key_validated?).once.and_return(true)
      adapter_mock = mock(Exceptional::Adapters::FileAdapter)
      adapter_mock.should_receive(:publish_exception)
      Exceptional::Adapters::FileAdapter.should_receive(:new).and_return(adapter_mock)

      Exceptional.post_exception(nil)
    end

    it "should instantiate HttpAsyncAdapter adapter" do
      Exceptional.should_receive(:adapter_name).once.and_return("HttpAsyncAdapter")
      Exceptional.should_receive(:api_key_validated?).once.and_return(true)
      adapter_mock = mock(Exceptional::Adapters::HttpAsyncAdapter)
      adapter_mock.should_receive(:publish_exception)
      Exceptional::Adapters::HttpAsyncAdapter.should_receive(:new).and_return(adapter_mock)
      Exceptional.post_exception(nil)
    end

    it "should raise Config error if invalid adapter configured" do
      Exceptional.should_receive(:adapter_name).twice.and_return("InvalidAdapterName")
      Exceptional.should_receive(:api_key_validated?).once.and_return(true)      
      lambda {Exceptional.post_exception(nil)}.should raise_error(Exceptional::AdapterManager::AdapterManagerException)
    end

  end

=begin
  describe "sending data " do

    it "should return response body if successful" do

      OK_RESPONSE_BODY = "ok" unless defined? OK_RESPONSE_BODY

      Exceptional.should_receive(:api_key_validated?).once.and_return(true)

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPSuccess)
      mock_http_response.should_receive(:kind_of?).with(Net::HTTPSuccess).once.and_return(true)
      mock_http_response.should_receive(:body).once.and_return(OK_RESPONSE_BODY)

      mock_http.should_receive(:start).once.and_return(mock_http_response)

      Exceptional.catch(IOError.new)
    end

    it "should raise error if network problem during sending exception" do

      Exceptional.should_receive(:api_key_validated?).once.and_return(true)

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPSuccess)

      mock_http.should_receive(:start).once.and_raise(IOError)

      #surpress the logging of the exception
      Exceptional.should_receive(:log!).exactly(3).times

      lambda{Exceptional.catch(IOError.new)}.should raise_error(Exceptional::Adapters::HttpAdapterException)
    end

    it "should raise Exception if sending exception unsuccessful" do

      Exceptional.should_receive(:api_key_validated?).once.and_return(true)

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPInternalServerError)
      mock_http_response.should_receive(:kind_of?).with(Net::HTTPSuccess).once.and_return(false)
      mock_http_response.should_receive(:code).once.and_return(501)
      mock_http_response.should_receive(:message).once.and_return("Internal Server Error")

      mock_http.should_receive(:start).once.and_return(mock_http_response)

      #surpress the logging of the exception
      Exceptional.should_receive(:log!).exactly(3).times

      lambda{Exceptional.catch(IOError.new)}.should raise_error(Exceptional::Adapters::HttpAdapterException)
    end
  end
=end
end
