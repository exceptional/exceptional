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
      Exceptional.should_receive(:work_dir?).twice.and_return(SWEEPER_WORK_DIR)

      FileTest.should_receive(:exists?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      FileTest.should_receive(:directory?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      Dir.should_not_receive(:mkdir)

      Exceptional::Utils::FileSweeper.new SWEEPER_CONFIG_FILE, SWEEPER_WORK_DIR, SWEEPER_APP_ROOT, mock_logger
    end

    it "should create work_dir if not available during initialization" do

      mock_logger = mock(Logger)
      mock_logger.stub!(:send)
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:work_dir?).any_number_of_times.and_return(SWEEPER_WORK_DIR)

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
      Exceptional.should_receive(:work_dir?).any_number_of_times.and_return(SWEEPER_WORK_DIR)

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
      Exceptional.should_receive(:work_dir?).any_number_of_times.and_return(SWEEPER_WORK_DIR)

      FileTest.should_receive(:exists?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      FileTest.should_receive(:directory?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      Dir.should_not_receive(:mkdir)

      mock_file = mock(File)

      Dir.should_receive(:glob).with(SWEEPER_WORK_DIR + '/*.json').and_return([])

      sweeper = Exceptional::Utils::FileSweeper.new SWEEPER_CONFIG_FILE, SWEEPER_WORK_DIR, SWEEPER_APP_ROOT, mock_logger
      sweeper.sweep
    end

    it "raise error if sweeping fails" do
      mock_logger = mock(Logger)
      mock_logger.stub!(:send)
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:work_dir?).any_number_of_times.and_return(SWEEPER_WORK_DIR)

      FileTest.should_receive(:exists?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      FileTest.should_receive(:directory?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
      Dir.should_not_receive(:mkdir)

      File.should_receive(:open).with("mock_file").and_raise(IOError)
      File.should_receive(:rename)
      
      Dir.should_receive(:glob).with(SWEEPER_WORK_DIR + '/*.json').and_return(["mock_file"])

      sweeper = Exceptional::Utils::FileSweeper.new SWEEPER_CONFIG_FILE, SWEEPER_WORK_DIR, SWEEPER_APP_ROOT, mock_logger
      lambda{sweeper.sweep}.should raise_error(Exceptional::Utils::FileSweeperException)
    end
  end

  it "processes exception in file" do
    mock_logger = mock(Logger)
    mock_logger.stub!(:send)
    Exceptional.should_receive(:setup_config)
    Exceptional.should_receive(:work_dir?).any_number_of_times.and_return(SWEEPER_WORK_DIR)

    FileTest.should_receive(:exists?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
    FileTest.should_receive(:directory?).with(SWEEPER_WORK_DIR).once.ordered.and_return(true)
    Dir.should_not_receive(:mkdir)

    
    files = ["file1", "file2", "file3"]

    Dir.should_receive(:glob).with(SWEEPER_WORK_DIR + '/*.json').and_return(files)

    sweeper = Exceptional::Utils::FileSweeper.new SWEEPER_CONFIG_FILE, SWEEPER_WORK_DIR, SWEEPER_APP_ROOT, mock_logger

    file_1_exception_data = "fl1exp"
    sweeper.should_receive(:read_data).with("file1").once.and_return(file_1_exception_data)
    sweeper.adapter.should_receive(:publish_exception).with(file_1_exception_data.to_json)
    File.should_receive(:delete).with("file1")

    file_2_exception_data = "fl2exp"
    sweeper.should_receive(:read_data).with("file2").once.and_return(file_2_exception_data)
    sweeper.adapter.should_receive(:publish_exception).with(file_2_exception_data.to_json)
    File.should_receive(:delete).with("file2")
    
    file_3_exception_data = "fl3exp"
    sweeper.should_receive(:read_data).with("file3").once.and_return(file_3_exception_data)
    sweeper.adapter.should_receive(:publish_exception).with(file_3_exception_data.to_json)
    File.should_receive(:delete).with("file3")
    sweeper.sweep
  end
end