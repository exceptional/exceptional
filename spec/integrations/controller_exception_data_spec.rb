require File.dirname(__FILE__) + '/spec_helper'
require 'digest/md5'


class Exceptional::FunkyError < StandardError
  def backtrace
    'backtrace'
  end
end

class BrokenJSON
  def to_json
    boom.time!
  end
end

describe Exceptional::ControllerExceptionData do
  it "raises useful error when to_json isn't available on to_hash" do
    request = ActionDispatch::TestRequest.new
    brokenJson = BrokenJSON.new
    session = {:boom => brokenJson}
    request.stub!(:session).and_return(session)
    data = Exceptional::ControllerExceptionData.new(Exceptional::FunkyError.new, nil, request)
    JSON.parse(data.to_json)['request']['session']['data'].should == {"boom" => brokenJson.to_s}
  end
end

describe Exceptional::ControllerDataExtractor do
    before do
      @request = mock(
        :protocol    => "http://",
        :host        => "mordor",
        :request_uri => "/walk_in",
        :params => 
          {
            "action" => "walk",
            "controller" => "ultimate",
            "foo"        => "bar"
          },
        :request_method => "GET",
        :ip             => "1.2.3.4",
        :env            => "fuzzy"
        )
        @controller = "Controller"
    end

    subject { Exceptional::ControllerDataExtractor.new(@controller, @request) }

    it "should extract the controller class" do
      subject.controller.should == "String"
    end

    it "should extract the URL" do
      subject.url.should == "http://mordor/walk_in"
    end

    it "should extract action" do
      subject.action.should == "walk"
    end

    it "should extract parameters" do
      subject.parameters.should == {
        "action" => "walk",
        "controller" => "ultimate",
        "foo" => "bar"
      }
    end

    it "should extract request method" do
      subject.request_method.should == "GET"
    end

    it "should extract remote ip" do
      subject.remote_ip.should == "1.2.3.4"
    end

    it "should extract env" do
      subject.env.should == "fuzzy"
    end

    it "should make request available" do
      subject.request.should == @request
    end

    context "with old request" do
      before do
        @request = mock(
          :url    => "http://mordor/walk_in",
          :parameters => 
          {
            "action" => "walk",
            "controller" => "ultimate",
            "foo"        => "bar"
          },
            :request_method => "GET",
            :remote_ip      => "1.2.3.4",
            :env            => "fuzzy"
        )
        @controller = "Controller"
      end

      subject { Exceptional::ControllerDataExtractor.new(@controller, @request) }

      it "should extract the URL" do
        subject.url.should == "http://mordor/walk_in"
      end

      it "should extract action" do
        subject.action.should == "walk"
      end

      it "should extract parameters" do
        subject.parameters.should == {
          "action" => "walk",
          "controller" => "ultimate",
          "foo" => "bar"
        }
      end

      it "should extract remote ip" do
        subject.remote_ip.should == "1.2.3.4"
      end
    end
end
