require File.dirname(__FILE__) + '/spec_helper'

describe 'Rake integration' do
  before :each do
    Exceptional::Config.stub!(:should_send_to_api?).and_return(true)
    Exceptional.stub(:handle)

    module Rake
      class Application
        def standard_exception_handling; end
        def display_error_message(exception); end
      end
    end
    load File.join(File.dirname(__FILE__), '..', 'lib', 'exceptional', 'integration', 'rake.rb')
    @application =  Rake::Application.new
    @exception = StandardError.new "Some rake error"
  end

  describe "Rake == 0.9.9.2" do
    it "should handle exceptions with Exceptional" do
      Exceptional::Catcher.should_receive(:handle).with(@exception)
      lambda do
        @application.standard_exception_handling do
          raise @exception
        end
      end.should raise_error SystemExit
    end
    it "should clear context" do
      Exceptional.should_receive(:clear!)
      lambda do
        @application.standard_exception_handling do
          raise @exception
        end
      end.should raise_error SystemExit
    end
  end
end
