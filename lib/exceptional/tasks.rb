namespace :exceptional do
  # require File.join(File.dirname(__FILE__), '../lib/exceptional')

  EXCEPTIONAL_CONFIG_FILE = "exceptional.yml"

  desc "Install Exceptional Plugin"
  task :rails_install do
    require 'ftools'
    require File.join(File.dirname(__FILE__), '/utils/rake_dir_tools')

    key = ENV['api_key']

    # Add Usage
    if key.nil?
      STDERR.puts "Usage 'rake install api_key=[API_KEY]"
      STDERR.puts " *** Exceptional Installation Failed "
      return
    end

    rails_root = Exceptional::Utils::RakeDirTools.get_rails_root

    exceptional_config_template = File.join(File.dirname(__FILE__), '../', EXCEPTIONAL_CONFIG_FILE)

    config_dir = Exceptional::Utils::RakeDirTools.get_config_dir

    if File.copy(exceptional_config_template, config_dir, true)
      new_config_file = File.join(config_dir, EXCEPTIONAL_CONFIG_FILE)

      s = 'PASTE_YOUR_API_KEY_HERE'
      r = key

      lines = []
      File.open(new_config_file, "r"){|f| lines = f.readlines }
      lines = lines.inject([]){|l, line| l << line.gsub(s, r)}
      File.open(new_config_file, "w"){|f| f.write(lines) }


      Exceptional.setup_config("test", new_config_file, rails_root)

      if !Exceptional.api_key_validate
        STDERR.puts "Error Authenticating API-Key"
        STDERR.puts " *** Exceptional Installation Failed "
        return
      end

    else
      STDERR.puts "Error copying config file"
      return
    end

    puts ""
    puts " ----- Exceptional Installation Successful ---- "
    puts "Config File :  #{File.expand_path(new_config_file)}"
    puts "Key : #{key}"
    puts ""
  end

  desc "Directory Sweeper for the File System Adapter"
  task :file_sweeper do

    require 'logger'
    require File.join(File.dirname(__FILE__), '/utils/file_sweeper')
    require File.join(File.dirname(__FILE__), '/utils/rake_dir_tools')

    config_file = Exceptional::Utils::RakeDirTools.get_config_file
    work_dir = Exceptional::Utils::RakeDirTools.get_work_dir
    rails_root = Exceptional::Utils::RakeDirTools.get_rails_root

    log_dir = File.join(rails_root, "log")
    Dir.mkdir(log_dir) unless File.directory?(log_dir)

    log_path = File.join(log_dir, "/exceptional_file_sweeper.log")
    log = Logger.new log_path
    log.formatter = Logger::Formatter.new

    sweeper = Exceptional::Utils::FileSweeper.new(config_file, work_dir, rails_root, log)

    sweeper.sweep()
  end
  
  desc "Send Test Exception to getexceptional.com"
    task :test do
      require File.join(File.dirname(__FILE__), '/utils/rake_dir_tools')

      environment = ENV['environment']

      # Add Usage
      if environment.nil?
        STDOUT.puts " Using environment 'development'"
        environment = 'development'
      end

      rails_root = Exceptional::Utils::RakeDirTools.get_rails_root
      config_file = Exceptional::Utils::RakeDirTools.get_config_file
      
      Exceptional.bootstrap(environment, rails_root, config_file)

      class Exceptional::TestException < StandardError; end

      Exceptional.catch(Exceptional::TestException.new('Test Exception'))      
    end    
end
