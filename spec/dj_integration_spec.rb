require File.dirname(__FILE__) + '/spec_helper'

module Delayed
  class Worker
    def handle_failed_job(job, exception)
      # do nothing for now
    end
    def name
      "My worker"
    end
  end
end

require File.join(File.dirname(__FILE__), '..', 'lib', 'exceptional', 'integration', 'dj')

describe Delayed::Worker do
  before :each do
    @worker =  Delayed::Worker.new
    @exception = StandardError.new
    @job = "dummy"
  end
  it "should handle exceptions with Exceptional" do
    Exceptional.should_receive(:handle).with(@exception, 'Delayed::Worker "My worker" died')
    @worker.handle_failed_job(@job, @exception)
  end
  it "should clear context" do
    Exceptional.should_receive(:clear!)
    @worker.handle_failed_job(@job, @exception)
  end
  it "should invoke the original handle_failed_job" do
    @worker.should_receive(:handle_failed_job_without_exceptional).with(@job, @exception)
    @worker.handle_failed_job(@job, @exception)    
  end
end