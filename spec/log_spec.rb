require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::Log do

  TEST_LOG_MESSAGE = "Test-log-message"

  before(:all) do
    log = Exceptional::Log

    def log.reset_state
      @log = nil
    end
  end

  after(:each) do
    Exceptional::Log.reset_state
  end


  it "setup should initialize the log " do
    Exceptional::Log.log.should be_nil
    Exceptional::Log.setup
    Exceptional::Log.log.should_not be_nil
  end

  it "setup should raise Configuration Exception if unable to initialize the log" do
    Exceptional::Log.log.should be_nil

    File.should_receive(:join).once.and_raise(IOError)

    lambda{Exceptional::Log.setup}.should raise_error(Exceptional::Config::ConfigurationException)

    Exceptional::Log.log.should be_nil
  end

  it "should default to logging to 'info'" do
    Exceptional::Log.setup
    Exceptional::Log.log.should_not be_nil

    Exceptional::Log.log.should_receive(:send).with("info", TEST_LOG_MESSAGE)
    Exceptional::Log.log! TEST_LOG_MESSAGE
  end

  it "should log to both STDERR and log file" do
    Exceptional::Log.setup
    Exceptional::Log.log.should_not be_nil

    Exceptional::Log.log.should_receive(:send).with("info", TEST_LOG_MESSAGE)
    STDERR.should_receive(:puts)

    Exceptional::Log.log! TEST_LOG_MESSAGE
  end

end
