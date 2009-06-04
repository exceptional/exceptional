require File.dirname(__FILE__) + '/spec_helper'
require 'rake'
require File.dirname(__FILE__) + '/../lib/exceptional/utils/rake_dir_tools'

describe "tasks" do

  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    load File.join(File.dirname(__FILE__), '..', 'lib', 'exceptional', 'tasks.rb')

  Exceptional.stub!(:to_stderr) # Don't print error when testing
    Exceptional.stub!(:log!) # Don't even attempt to log
    Exceptional.stub!(:to_log)
    STDOUT.stub!(:puts)
    STDERR.stub!(:puts)

    def Exceptional.reset_adapter
      @adapter = nil
      @api_key_validated = nil
    end

    Exceptional.reset_adapter
  end

  after(:each) do
    Rake.application = nil
    Exceptional.reset_adapter
  end

  describe "exceptional:test" do
    it "should sent test exception to server if authentication successful" do
      Exceptional.should_receive(:bootstrap)
      Exceptional.should_receive(:api_key_validate).twice.and_return(true)
      Exceptional.adapter.should_receive(:publish_exception)

      Exceptional::Utils::RakeDirTools.should_receive(:get_config_file)

      @rake["exceptional:test"].invoke
    end

    it "should not send test exception to server if authentication un-successful" do
      Exceptional.should_receive(:bootstrap)
      Exceptional.should_receive(:api_key_validate).once.and_return(false)
      Exceptional.adapter.should_not_receive(:publish_exception)

      Exceptional::Utils::RakeDirTools.should_receive(:get_config_file)

      @rake["exceptional:test"].invoke
    end
  end

  describe "exceptional:rails_install" do
    it "should try and authenticate & fail" do
      Exceptional.should_receive(:setup_config)
      File.should_receive(:open).twice
      ENV["api_key"] = "test-api-key".freeze
      Exceptional.should_receive(:api_key_validate).once.and_return(false)

      Exceptional::Utils::RakeDirTools.should_receive(:get_config_file)

      @rake["exceptional:rails_install"].invoke
    end

    it "should try and authenticate & suceed" do
      Exceptional.should_receive(:setup_config)
      File.should_receive(:open).twice
      ENV["api_key"] = "test-api-key".freeze
      Exceptional.should_receive(:api_key_validate).once.and_return(true)

      Exceptional::Utils::RakeDirTools.should_receive(:get_config_file).and_return("/config/path/configfile.yml")

      @rake["exceptional:rails_install"].invoke
    end
  end

  describe "exceptional:file_sweeper" do
    it "should try and create the work_dir" do

      mock_logger = mock(Logger)
      mock_logger.should_receive(:formatter=).once
      Logger.should_receive(:new).once.and_return(mock_logger)

      mock_sweeper = mock(Exceptional::Utils::FileSweeper)
      mock_sweeper.should_receive(:sweep)
      Exceptional::Utils::FileSweeper.should_receive(:new).and_return(mock_sweeper)
      
      Exceptional::Utils::RakeDirTools.should_receive(:get_config_file).and_return("/config/path/configfile.yml")
            
      @rake["exceptional:file_sweeper"].invoke
    end
  end

end
