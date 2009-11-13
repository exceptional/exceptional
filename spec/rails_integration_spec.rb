require File.dirname(__FILE__) + '/spec_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'exceptional', 'integration', 'rails')

describe Exceptional, 'version number' do
  it "be available proramatically" do
    Exceptional::VERSION.should == '0.2.0'
  end
end

describe ActiveSupport::JSON, 'standards compliant json' do
  it "quote keys" do
    {:a => '123'}.to_json.gsub(/ /,'').should == '{"a":"123"}'
  end
end

class TestingController < ActionController::Base
  def raises_something
    raise StandardError
  end
end

describe TestingController do
  before :each do
    @controller = TestingController.new
  end

  it 'handle exception with Exceptional::Catcher' do
    Exceptional::Catcher.should_receive(:handle).with(an_instance_of(StandardError), @controller, an_instance_of(ActionController::TestRequest))
    send_request(:raises_something)
  end

  it "still return an error response to the user" do
    Exceptional::Catcher.stub!(:handle)
    send_request(:raises_something)
    @response.code.should == '500'
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
    def custom_handler
      head :ok
    end
  end

  describe TestingWithRescueFromController do
    before :each do
      @controller = TestingWithRescueFromController.new
    end

    it 'not handle exception with Exceptional that is dealt with by rescue_from' do
      Exceptional::Catcher.should_not_receive(:handle)
      send_request(:raises_custom_error)
    end
    it 'handle exception with Exceptional that is not dealt with by rescue_from' do
      Exceptional::Catcher.should_receive(:handle)
      send_request(:raises_other_error)
    end
  end
end