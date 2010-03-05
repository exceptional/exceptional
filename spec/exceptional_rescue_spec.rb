require File.dirname(__FILE__) + '/spec_helper'

context 'resuce errors from within a block' do
  class FunkyException < StandardError;
  end
  it "Exceptional.rescue should send to exceptional and swallow error " do
    to_raise = FunkyException.new
    Exceptional::Catcher.should_receive(:handle).with(to_raise, 'my rescue name')
    Exceptional.rescue('my rescue name') do
      raise to_raise
    end
  end

  it "reraises error with rescue_and_reraise" do
    to_raise = FunkyException.new
    Exceptional::Catcher.should_receive(:handle).with(to_raise, 'my rescue name')
    begin
      Exceptional.rescue_and_reraise('my rescue name') do
        raise to_raise
      end
      fail 'expected a reraise'
    rescue FunkyException => e
    end
  end

  it "Exceptional.handle calls Exceptional::Catcher.handle" do
    to_raise = FunkyException.new
    Exceptional::Catcher.should_receive(:handle).with(to_raise, 'optional name for where it has occurred')
    begin
      raise to_raise
    rescue => e
      Exceptional.handle(e, 'optional name for where it has occurred')
    end
  end

  it "collects context information but leaves thread local empty after block" do
    to_raise = FunkyException.new
    Exceptional::Config.should_receive(:should_send_to_api?).and_return(true)
    Exceptional::Remote.should_receive(:error) {|exception_data|
      exception_data.to_hash['context']['foo'] == 'bar'
      exception_data.to_hash['context']['baz'] == 42
      exception_data.to_hash['context']['cats'] == {'lol' => 'bot'}
    }
    Exceptional.rescue('my rescue name') do
      Exceptional.context('foo' => 'bar')
      Exceptional.context('baz' => 42)
      Exceptional.context('cats' => {'lol' => 'bot'})
      raise to_raise
    end
    Thread.current[:exceptional_context].should == nil
  end

  it "clearr context with Exceptional.context.clear!" do
    Exceptional.context('foo' => 'bar')
    Thread.current[:exceptional_context].should_not == nil
    Exceptional.context.clear!
    Thread.current[:exceptional_context].should == nil
  end

  it "allows optional second paramater hash to get added to context" do
    Exceptional.should_receive(:context).with(context_hash = {'foo' => 'bar', 'baz' => 42})
    Exceptional.rescue('my rescue', context_hash) {}
  end
  
  it "should clear context after every invocation" do
    Thread.current[:exceptional_context].should == nil

    Exceptional.rescue('my rescue', context_hash = {'foo' => 'bar', 'baz' => 42}) {
      Thread.current[:exceptional_context].should_not == nil      
    }
    
    Thread.current[:exceptional_context].should == nil        
  end
end