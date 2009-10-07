require File.dirname(__FILE__) + '/../spec_helper'

class Exceptional::FunkyError < StandardError
  def backtrace
    'backtrace'
  end
end

describe Exceptional::ExceptionData do
  it "create hash for exception only" do
    error = Exceptional::FunkyError.new('some message')
    data = Exceptional::ExceptionData.new(error)
    hash = data.to_hash
    error_hash = hash['exception']
    error_hash['exception_class'].should == 'Exceptional::FunkyError'
    error_hash['exception_message'].should == 'some message'
    error_hash['exception_backtrace'].should == 'backtrace'
  end
end