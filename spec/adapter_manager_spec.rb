require File.dirname(__FILE__) + '/spec_helper'


describe Exceptional::AdapterManager do
  
  describe "sending data " do

    it "should return response body if successful" do
      
      Exceptional.should_receive(:api_key_validated?).once.and_return(true)
      
      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPSuccess)
      mock_http_response.should_receive(:kind_of?).with(Net::HTTPSuccess).once.and_return(true)
      mock_http_response.should_receive(:body).once.and_return(OK_RESPONSE_BODY)

      mock_http.should_receive(:start).once.and_return(mock_http_response)

      exception_data = mock(Exceptional::ExceptionData,
      :message => "Something bad has happened",
      :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"],
      :class => Exception,
      :to_hash => { :message => "Something bad has happened" })
      
      Exceptional.post(exception_data).should == OK_RESPONSE_BODY
    end

    it "should raise error if network problem during sending exception" do

      Exceptional.should_receive(:api_key_validated?).once.and_return(true)

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPSuccess)

      mock_http.should_receive(:start).once.and_raise(IOError)

      #surpress the logging of the exception
      Exceptional.should_receive(:log!).twice
      
      exception_data = mock(Exceptional::ExceptionData,
      :message => "Something bad has happened",
      :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"],
      :class => Exception,
      :to_hash => { :message => "Something bad has happened" })
      

      lambda{Exceptional.post(exception_data)}.should raise_error(Exceptional::Adapters::HttpAdapterException)
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
      Exceptional.should_receive(:log!).twice

      exception_data = mock(Exceptional::ExceptionData,
      :message => "Something bad has happened",
      :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"],
      :class => Exception,
      :to_hash => { :message => "Something bad has happened" })

      lambda{Exceptional.post(exception_data)}.should raise_error(Exceptional::Adapters::HttpAdapterException)
    end
  end
end