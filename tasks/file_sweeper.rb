namespace :exceptional do
  require File.join(File.dirname(__FILE__), '../lib/exceptional')

  desc "Directory Sweeper for the File System Adapter"
  task :file_sweeper do

    require 'logger'
    require File.join(File.dirname(__FILE__), 'lib/exceptional/utils/file_sweeper')
    require File.join(File.dirname(__FILE__), 'lib/exceptional/utils/rake_dir_tools')
    
    config_file = Exceptional::Utils::RakeDirTools.get_config_file
    work_dir = Exceptional::Utils::RakeDirTools.get_work_dir
    rails_root = Exceptional::Utils::RakeDirTools.get_rails_root

    log_dir = File.join(rails_root, "log")
    Dir.mkdir(log_dir) unless File.directory?(log_dir)

    log_path = File.join(log_dir, "/exceptional_file_sweeper.log")
    log = Logger.new log_path

    sweeper = Exceptional::Utils::FileSweeper.new(config_file, work_dir, rails_root, log)

    sweeper.sweep()
  end
end
