require File.dirname(__FILE__) + '/spec_helper'


describe "Delayed Job integration for DJ < 1.8.5" do
  before do
    module Delayed
      class Worker
      end
    end
  end
  it "should report the lack of support to STDERR" do
    STDERR.should_receive(:puts).with("\n\n\nThe Exceptional gem does not support Delayed Job 1.8.4 or earlier.\n\n\n")
    load File.join(File.dirname(__FILE__), '..', 'lib', 'exceptional', 'integration', 'dj.rb')
  end  
  it "should report the lack of support to Exceptional.logger" do
    STDERR.stub(:puts)
    Exceptional.logger.should_receive(:error).with("\n\n\nThe Exceptional gem does not support Delayed Job 1.8.4 or earlier.\n\n\n")
    load File.join(File.dirname(__FILE__), '..', 'lib', 'exceptional', 'integration', 'dj.rb')
  end
end

describe 'Delayed Job integration' do
  before :each do
    Exceptional::Config.stub!(:should_send_to_api?).and_return(true)
    Exceptional.stub(:handle)

    module Delayed
      class Worker
        def handle_failed_job(job, exception); end
      end
    end
    load File.join(File.dirname(__FILE__), '..', 'lib', 'exceptional', 'integration', 'dj.rb')
    @worker =  Delayed::Worker.new
    @exception = StandardError.new
    @job = mock(:name => "My delayed job")
  end
  describe "For Delayed Job > 1.8.5" do
    it "should handle exceptions with Exceptional" do
      Exceptional.should_receive(:handle).with(@exception, 'Delayed::Job My delayed job')
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
end