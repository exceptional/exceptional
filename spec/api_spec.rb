require File.dirname(__FILE__) + '/spec_helper'


describe Exceptional::Api do


  describe "with no configuration" do
    before(:each) do
    Exceptional.stub!(:to_stderr) # Don't print error when testing
    end

    after(:each) do
      Exceptional.api_key= nil
    end

    it "should connect to getexceptional.com by default" do
      Exceptional.remote_host.should == "getexceptional.com"
    end

    it "should connect to port 80 by default" do
      Exceptional.remote_port.should == 80
    end

    it "should parse exception into exception data object" do
      exception = mock(Exception, :message => "Something bad has happened",
      :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"])
      exception_data = Exceptional.parse(exception)
      exception_data.kind_of?(Exceptional::ExceptionData).should be_true
      exception_data.exception_message.should == exception.message
      exception_data.exception_backtrace.should == exception.backtrace
      exception_data.exception_class.should == exception.class.to_s


    end

    it "should post exception" do

      exception_data = mock(Exceptional::ExceptionData,
      :message => "Something bad has happened",
      :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"],
      :class => Exception, :to_hash => { :message => "Something bad has happened" })
      Exceptional.api_key = "TEST_API_KEY"
      Exceptional.should_receive(:authenticate).once.and_return(true)
      Exceptional.should_receive(:call_remote, :with => [:errors, exception_data]).once
      Exceptional.post(exception_data)

    end

    it "should catch exception" do
      exception = mock(Exception, :message => "Something bad has happened",
      :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"])

      exception_data = mock(Exceptional::ExceptionData,
      :message => "Something bad has happened",
      :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"],
      :class => Exception, :to_hash => { :message => "Something bad has happened" })
      exception_data.should_receive(:controller_name=).with(File.basename($0))

      Exceptional.should_receive(:parse, :with => [exception]).and_return(exception_data)
      Exceptional.should_receive(:post, :with => [exception_data])

      Exceptional.catch(exception)
    end

    it "should raise a license exception if api key is not set" do
      exception_data = mock(Exceptional::ExceptionData,
      :message => "Something bad has happened",
      :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"],
      :class => Exception,
      :to_hash => { :message => "Something bad has happened" })
      Exceptional.api_key.should == nil
      lambda { Exceptional.post(exception_data) }.should raise_error(Exceptional::Config::ConfigurationException)
    end
  end

  describe "rescue" do

    it "should send exception data onto catch" do
      Exceptional.should_receive(:catch)
      lambda{ Exceptional.rescue do
        raise IOError
      end}.should raise_error(IOError)

    end
  end

  describe "handle" do
    before(:each) do
      Exceptional.stub!(:to_stderr) # Don't print error when testing
    end

    it "should send exception data onto post" do
      exception = mock(Exception, :message => "Something bad has happened",
      :backtrace => "/app/controllers/buggy_controller.rb:29:in `index'")

      controller = mock("controller", :controller_name => "Test Controller Name", :action_name => "Test Action Name")

      class SessionHelper
        def initialize
          @some_var = 1
          @cgi_var = 2
          @x_db = 3
        end
      end

      request = mock("request", :env => {"key1" => "val1"}, :protocol => "http", :host => "getexceptional.com", :request_uri => "/path/to/resource", :session => SessionHelper.new)

      Exceptional.should_receive(:post_exception).once
      Exceptional.handle(exception, controller, request, {:clients => {:name => "bar"}})
    end
  end

  describe "with helper methods" do

    it "safe_environment() should delete all rack related stuff from environment" do
      request = mock(request, :env => { 'rack_var' => 'value', 'non_ack' => 'value2' })
      Exceptional.send(:safe_environment, request).should == { 'non_ack' => 'value2' }
    end

    it "safe_session() should filter all /db/, /cgi/ variables and sub @ for blank" do
      class SessionHelper
        def initialize
          @some_var = 1
          @cgi_var = 2
          @x_db = 3
        end
      end

      session = SessionHelper.new
      Exceptional.send(:safe_session, session).should == { 'some_var' => 1 }
    end

    it "sanitize_hash() should sanitize cyclic problem for to_json" do
      class MyClass
        def initialize
          @test = self
        end

        def to_hash
          { :test => self }
        end
      end
      my_class = MyClass.new

      lambda { my_class.to_json }.should raise_error(ActiveSupport::JSON::CircularReferenceError)
      Exceptional.send(:sanitize_hash, my_class.to_hash).to_json.should be_kind_of(String)
    end
  end
end