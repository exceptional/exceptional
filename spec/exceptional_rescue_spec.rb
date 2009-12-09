require File.dirname(__FILE__) + '/spec_helper'

context 'resuce errors from within a block' do
  class FunkyException < StandardError; end
  it "send them to catcher with optional name" do
    to_raise = FunkyException.new
    Exceptional::Catcher.should_receive(:handle_without_controller).with(to_raise, 'my rescue name')
    begin
      Exceptional.rescue('my rescue name') do
        raise to_raise
      end
      fail "expected to raise"
    rescue FunkyException => e
      e.should == to_raise
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
    begin
      Exceptional.rescue('my rescue name') do
        Exceptional.context('foo' => 'bar')
        Exceptional.context('baz' => 42)
        Exceptional.context('cats' => {'lol' => 'bot'})
        raise to_raise
      end
      fail "expected to raise"
    rescue FunkyException => e
      e.should == to_raise
    end
    Thread.current[:exceptional_context].should == nil
  end
end