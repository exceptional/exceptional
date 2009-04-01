require File.dirname(__FILE__) + '/spec_helper'
require 'net/http'

describe Exceptional::Remote do

  describe "sending data " do

    it "should return response body if successful" do

      OK_RESPONSE_BODY = "OK-RESP-BODY"
      
      Exceptional.api_key = TEST_API_KEY
      Exceptional.authenticated?.should be_false

      Exceptional.should_receive(:authenticated?).once.and_return(true)

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPSuccess)
      mock_http_response.should_receive(:kind_of?).with(Net::HTTPSuccess).once.and_return(true)
      mock_http_response.should_receive(:body).once.and_return(OK_RESPONSE_BODY)

      mock_http.should_receive(:start).once.and_return(mock_http_response)

      Exceptional.post_exception("data").should == OK_RESPONSE_BODY
    end
    
    it "should raise error if network problem during sending exception" do

      Exceptional.api_key = TEST_API_KEY
      Exceptional.authenticated?.should be_false

      Exceptional.should_receive(:authenticated?).once.and_return(true)

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPSuccess)

      mock_http.should_receive(:start).once.and_raise(IOError)

      #surpress the logging of the exception
      Exceptional.should_receive(:log!).twice

      lambda{Exceptional.post_exception("data")}.should raise_error(IOError) 
    end

    it "should raise Exception if sending exception unsuccessful" do

      Exceptional.api_key = TEST_API_KEY
      Exceptional.authenticated?.should be_false

      Exceptional.should_receive(:authenticated?).once.and_return(true)

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPInternalServerError)
      mock_http_response.should_receive(:kind_of?).with(Net::HTTPSuccess).once.and_return(false)
      mock_http_response.should_receive(:code).once.and_return(501)
      mock_http_response.should_receive(:message).once.and_return("Internal Server Error")

      mock_http.should_receive(:start).once.and_return(mock_http_response)

      #surpress the logging of the exception
      Exceptional.should_receive(:log!).twice

      lambda{Exceptional.post_exception("data")}.should raise_error(Exceptional::Utils::HttpUtils::HttpUtilsException) 
    end    
  end
end
