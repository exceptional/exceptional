require File.dirname(__FILE__) + '/../spec_helper'

class Exceptional::FunkyError < StandardError
  def backtrace
    'backtrace'
  end
end

describe Exceptional::ExceptionData do
  it "create hash for exception only" do
    Time.stub!(:now).and_return(now = Time.mktime(1970,1,1))
    error = Exceptional::FunkyError.new('some message')
    data = Exceptional::ExceptionData.new(error)
    hash = data.to_hash
    error_hash = hash['exception']
    error_hash['exception_class'].should == 'Exceptional::FunkyError'
    error_hash['message'].should == 'some message'
    error_hash['backtrace'].should == 'backtrace'
    error_hash['occurred_at'].should == now.strftime("%Y%m%d %H:%M:%S %Z")
    client_hash = hash['client']
    client_hash['name'].should == Exceptional::CLIENT_NAME
    client_hash['version'].should == Exceptional::VERSION    
  end
end