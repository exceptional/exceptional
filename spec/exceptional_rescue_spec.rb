require File.dirname(__FILE__) + '/spec_helper'

context 'resuce errors from within a block' do
  class FunkyException < StandardError; end
  it "send them to catcher and reraise" do
    to_raise = FunkyException.new
    Exceptional::Catcher.should_receive(:handle).with(to_raise)
    begin
      Exceptional.rescue do
        raise to_raise
      end
      fail "expected to raise"
    rescue FunkyException => e
      e.should == to_raise
    end
  end
end