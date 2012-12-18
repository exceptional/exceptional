require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::Catcher do
  describe "when Exceptional reporting is on" do

    before do
      Exceptional::Config.stub(:should_send_to_api?).and_return(true)
    end

    describe "#handle_with_controller" do

      it "should create ControllerExceptionData object and send json to the api" do
        exception = mock('exception')
        controller = mock('controller')
        request = mock('request')
        args = [exception, controller, request]
        data = mock("exception_data")

        Exceptional::ControllerExceptionData.should_receive(:new).with(*args).
          and_return(data)
        Exceptional::Sender.should_receive(:error).with(data)
        Exceptional::Catcher.handle_with_controller(*args)
      end

    end

    describe "#handle_with_rack" do

      it "should create RackExceptionData object and send json to the api" do
        exception = mock("exception")
        environment = mock("environment")
        request = mock("request")
        args = [exception, environment, request]
        data = mock("exception_data")

        Exceptional::RackExceptionData.should_receive(:new).with(*args).
          and_return(data)
        Exceptional::Sender.should_receive(:error).with(data)
        Exceptional::Catcher.handle_with_rack(*args)
      end

    end

    describe "#handle" do

      it "should create ExceptionData object and send json to the api" do
        exception = mock("exception")
        name = mock("name")
        args = [exception, name]
        data = mock("data")

        Exceptional::ExceptionData.should_receive(:new).with(*args).
          and_return(data)
        Exceptional::Sender.should_receive(:error).with(data)
        Exceptional::Catcher.handle(*args)
      end
    end

    describe "#ignore?" do

      before do
        @exception = mock('exception')
        @controller = mock('controller')
        @request = mock('request')
      end

      it "should check for ignored classes and agents" do
        Exceptional::Catcher.should_receive(:ignore_class?).with(@exception)
        Exceptional::Catcher.should_receive(:ignore_user_agent?).with(@request)
        Exceptional::ControllerExceptionData.should_receive(:new).
          with(@exception,@controller,@request).
          and_return(data = mock('exception_data'))
        Exceptional::Sender.should_receive(:error).with(data)

        Exceptional::Catcher.handle_with_controller(@exception,
                                                    @controller,
                                                    @request)
      end

      it "should ignore exceptions by class name" do
        request = mock("request")
        exception = mock("exception")
        exception.stub(:class).and_return("ignore_me")
        exception.should_receive(:class)

        Exceptional::Config.ignore_exceptions = ["ignore_me",/funky/]
        Exceptional::Catcher.ignore_class?(exception).should be_true
        funky_exception = mock("exception")
        funky_exception.stub(:class).and_return("really_funky_exception")
        funky_exception.should_receive(:class)

        Exceptional::Catcher.ignore_class?(funky_exception).should be_true
      end

      it "should ignore exceptions by user agent" do
        request = mock("request")
        request.stub(:user_agent).and_return("botmeister")
        request.should_receive(:user_agent)

        Exceptional::Config.ignore_user_agents = [/bot/]
        Exceptional::Catcher.ignore_user_agent?(request).should be_true
      end

    end
  end

  describe "when Exceptional reporting is off" do

    before do
      Exceptional::Config.stub(:should_send_to_api?).and_return(false)
    end

    describe "#handle, #handle_with_controller and #handle_with_rack" do

      it "should reraise the exception and not report it" do
        exception = mock('exception')
        controller = mock('controller')
        request = mock('request')

        Exceptional::ControllerExceptionData.should_not_receive(:new)
        Exceptional::Sender.should_not_receive(:error)

        ["rails", "rack", ""].each do |handler|
          method_name = "handle"
          method_name << "_with_#{handler}" unless handler.empty? 
          expect do
            Exceptional::Catcher.send(method_name, exception, controller, request)
          end.to raise_exception
        end
      end
    end
  end
end
