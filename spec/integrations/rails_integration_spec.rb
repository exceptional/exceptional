require File.dirname(__FILE__) + '/spec_helper'
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'exceptional', 'integration', 'rails')

describe Exceptional, 'version number' do
  it "be available proramatically" do
    Exceptional::VERSION.should =~ /\d+\.\d+\.\d+/
  end
end

describe ActiveSupport::JSON, 'standards compliant json' do
  it "quote keys" do
    {:a => '123'}.to_json.gsub(/ /, '').should == '{"a":"123"}'
  end
end

class ExceptionalController < ActionController::Base
  def show_detailed_exceptions?
    true
  end
end

class SimpleController < ExceptionalController
  # filter_parameter_logging :password, /credit_card/ RAILS 2

  def raises_something
    raise StandardError
  end
end


class IgnoreAgentController < ExceptionalController

  class IgnoredError < StandardError; end

  def raises_something
    raise
  end

  def raise_but_ignore
    request.env["HTTP_USER_AGENT"] = "BOTMEISTER"
    raise StandardError
  end

  def raise_but_ignore_with_regex
    raise IgnoredError
  end

  def local_request?
    true
  end
end

describe IgnoreAgentController do
  before :each do
    Exceptional::Config.ignore_user_agents = ["BOTMEISTER"]
    Exceptional::Config.api_key = "api_key"
    Exceptional::Config.stub!(:should_send_to_api?).and_return(true)
    @controller = IgnoreAgentController
  end

  it "should send the exception if agent is not ignored" do
    Exceptional::Sender.should_receive(:error)
    send_request :raises_something
  end

  it "should not send the exception if agent is ignored" do
    Exceptional::Sender.should_not_receive(:error)
    send_request :raise_but_ignore
  end

  it "should not send the exception if class is ignored with regex" do
    Exceptional::Config.ignore_exceptions = [/IgnoredError/]
    Exceptional::Sender.should_not_receive(:error)
    send_request :raise_but_ignore_with_regex
  end
end

 describe SimpleController do
   before :each do
    Exceptional::Config.api_key = "api_key"
    Exceptional::Config.stub!(:should_send_to_api?).and_return(true)
    @controller = SimpleController
   end

   it 'handle exception with Exceptional::Catcher' do
     Exceptional::Catcher.should_receive(:handle_with_controller).
       with(
         an_instance_of(StandardError),
         an_instance_of(SimpleController),
         an_instance_of(Rack::Request)
           )
       send_request :raises_something
   end
 end


if ActionController::Base.respond_to?(:rescue_from)
  class CustomError < StandardError; end
  class TestingWithRescueFromController < ActionController::Base
    rescue_from CustomError, :with => :custom_handler

    def raises_custom_error
      raise CustomError.new
    end

    def raises_other_error
      raise StandardError.new
    end

    def raises_with_context
      Exceptional.context('foo' => 'bar')
      raise StandardError.new
    end

    def custom_handler
      head :ok
    end
  end

  describe TestingWithRescueFromController do
    before :each do
      Exceptional::Config.api_key = "api_key"
      Exceptional::Config.stub!(:should_send_to_api?).and_return(true)
      @controller = TestingWithRescueFromController
    end

    it 'not handle exception with Exceptional that is dealt with by rescue_from' do
      Exceptional::Catcher.should_not_receive(:handle_with_controller)
      send_request(:raises_custom_error)
    end
    it 'handle exception with Exceptional that is not dealt with by rescue_from' do
      Exceptional::Catcher.should_receive(:handle_with_controller)
      send_request(:raises_other_error)
    end
    it "has context and clears context after request" do
      Exceptional::Sender.should_receive(:error) {|exception_data|
        exception_data.to_hash['context']['foo'] == 'bar'
      }
      send_request(:raises_with_context)
      Thread.current[:exceptional_context].should == nil
    end
  end
end
