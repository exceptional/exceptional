require File.dirname(__FILE__) + '/../spec_helper'


describe Exceptional::Utils::FileSweeper do

  SWEEPER_CONFIG_FILE = "config.yml"
  SWEEPER_WORK_DIR = "tmp/work_dir"
  SWEEPER_APP_ROOT = "app_root"
  SWEEPER_LOG = "sweeper_log"

  describe "initialization" do

    it "should ensure work_dir is available during initialization" do

      mock_logger = mock(Logger)
      mock_logger.stub!(:send)
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:work_dir).twice.and_return(SWEEPER_WORK_DIR)

      FileTest.should_receive(:exists?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      FileTest.should_receive(:directory?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      Dir.should_not_receive(:mkdir)

      Exceptional::Utils::FileSweeper.new SWEEPER_CONFIG_FILE, SWEEPER_WORK_DIR, SWEEPER_APP_ROOT, mock_logger
    end

    it "should create work_dir if not available during initialization" do

      mock_logger = mock(Logger)
      mock_logger.stub!(:send)
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:work_dir).any_number_of_times.and_return(SWEEPER_WORK_DIR)

      FileTest.should_receive(:exists?).with(SWEEPER_WORK_DIR).once.ordered.and_return(false)
      #    FileTest.should_receive(:directory?).with(SWEEPER_WORK_DIR).once.ordered.and_return(false)
      FileTest.should_receive(:exists?).with(File.dirname(SWEEPER_WORK_DIR)).once.ordered.and_return(true)
      Dir.should_receive(:mkdir)

      Exceptional::Utils::FileSweeper.new SWEEPER_CONFIG_FILE, SWEEPER_WORK_DIR, SWEEPER_APP_ROOT, mock_logger
    end

    it "should raise error if directory config wrong" do
      mock_logger = mock(Logger)
      mock_logger.stub!(:send)
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:work_dir).any_number_of_times.and_return(SWEEPER_WORK_DIR)

      FileTest.should_receive(:exists?).with(SWEEPER_WORK_DIR).once.ordered.and_return(false)
      #    FileTest.should_receive(:directory?).with(SWEEPER_WORK_DIR).once.ordered.and_return(false)
      FileTest.should_receive(:exists?).with(File.dirname(SWEEPER_WORK_DIR)).once.ordered.and_return(false)

      lambda{Exceptional::Utils::FileSweeper.new SWEEPER_CONFIG_FILE, SWEEPER_WORK_DIR, SWEEPER_APP_ROOT, mock_logger}.should raise_error(Exceptional::Utils::FileUtils::FileUtilsException)
    end
  end

  describe "sweeping directory" do
    it "sends exception file if found" do
      mock_logger = mock(Logger)
      mock_logger.stub!(:send)
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:work_dir).any_number_of_times.and_return(SWEEPER_WORK_DIR)

      FileTest.should_receive(:exists?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      FileTest.should_receive(:directory?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      Dir.should_not_receive(:mkdir)

      mock_file = mock(File)      
            
      Dir.should_receive(:glob).with(SWEEPER_WORK_DIR + '/*.json').and_return {mock_file}

      sweeper = Exceptional::Utils::FileSweeper.new SWEEPER_CONFIG_FILE, SWEEPER_WORK_DIR, SWEEPER_APP_ROOT, mock_logger
      sweeper.sweep
    end
    
    it "raise error if sweeping fails" do
      mock_logger = mock(Logger)
      mock_logger.stub!(:send)
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:work_dir).any_number_of_times.and_return(SWEEPER_WORK_DIR)

      FileTest.should_receive(:exists?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      FileTest.should_receive(:directory?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      Dir.should_not_receive(:mkdir)

      mock_file = mock(File)
      
      Dir.should_receive(:glob).with(SWEEPER_WORK_DIR + '/*.json').and_raise(IOError)

      sweeper = Exceptional::Utils::FileSweeper.new SWEEPER_CONFIG_FILE, SWEEPER_WORK_DIR, SWEEPER_APP_ROOT, mock_logger
      lambda{sweeper.sweep}.should raise_error(Exceptional::Utils::FileSweeperException)
    end
  end
end
