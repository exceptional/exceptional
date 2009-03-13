require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::Agent::Worker do 
  
  before(:each) do
    # pass a nil logger object to the worker to clean up rspec output
    @worker = Exceptional::Agent::Worker.new(nil)
  end
  
  describe "after initialisation" do
    
    it "should default worker timeout" do
      @worker.timeout.should == 10
    end
  
    it "should have no exceptions" do
      @worker.exceptions.should == []
    end
    
  end
  
end
