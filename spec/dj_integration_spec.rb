require File.dirname(__FILE__) + '/spec_helper'

module Delayed
  class Job
    def log_exception(exception)
    # do nothing for now
  end
  def name
    "My delayed job"
  end
  end
end

require File.join(File.dirname(__FILE__), '..', 'lib', 'exceptional', 'integration', 'dj')

describe Delayed::Job do
  before :each do
    @job =  Delayed::Job.new
    @exception = StandardError.new
  end
  it "should handle exceptions with Exceptional" do
    Exceptional.should_receive(:handle).with(@exception, "Delayed::Job My delayed job")
    @job.log_exception(@exception)
  end
  it "should clear context" do
    Exceptional.should_receive(:clear!)
    @job.log_exception(@exception)
  end
end