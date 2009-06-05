namespace :exceptional do
  # require File.join(File.dirname(__FILE__), '../lib/exceptional')

  EXCEPTIONAL_CONFIG_FILE = "exceptional.yml" unless defined? EXCEPTIONAL_CONFIG_FILE

  desc "Install Exceptional Plugin"
  task :rails_install do
    require 'ftools'
    require File.join(File.dirname(__FILE__), '/utils/rake_dir_tools')
    require File.join(File.dirname(__FILE__), '..', 'exceptional')    
    require 'json'

    key = ENV['api_key']

    # Add Usage
    if key.nil?
      STDERR.puts "Usage 'rake install api_key=[API_KEY]"
      STDERR.puts " *** Exceptional Installation Failed "
      return
    end

    rails_root = Exceptional::Utils::RakeDirTools.get_rails_root
    config_file = Exceptional::Utils::RakeDirTools.get_config_file

    s = 'PASTE_YOUR_API_KEY_HERE'
    r = key

    lines = []
    File.open(config_file, "r"){|f| lines = f.readlines }
    lines = lines.inject([]){|l, line| l << line.gsub(s, r)}
    File.open(config_file, "w"){|f| f.write(lines) }

    Exceptional.setup_config("development", config_file, rails_root)

    if !Exceptional.api_key_validate
      STDERR.puts "Error Authenticating API-Key"
      STDERR.puts "Exceptional Installation Failed"      
    else 
      STDOUT.puts ""
      STDOUT.puts " ----- Exceptional Installation Successful ---- "
      STDOUT.puts "Config File :  #{File.expand_path(config_file)}"
      STDOUT.puts "Key : #{key}"
      STDOUT.puts ""      
    end
  end

  desc "Directory Sweeper for the File System Adapter"
  task :file_sweeper do

    require 'logger'
    require File.join(File.dirname(__FILE__), '/utils/file_sweeper')
    require File.join(File.dirname(__FILE__), '/utils/rake_dir_tools')
    require File.join(File.dirname(__FILE__), '..', 'exceptional')    

    config_file = Exceptional::Utils::RakeDirTools.get_config_file
    work_dir = Exceptional::Utils::RakeDirTools.get_work_dir
    rails_root = Exceptional::Utils::RakeDirTools.get_rails_root

    log_dir = File.join(rails_root, "log")
    log_path = File.join(log_dir, "/exceptional_file_sweeper.log")
    
    log = Logger.new log_path
    log.formatter = Logger::Formatter.new

    sweeper = Exceptional::Utils::FileSweeper.new(config_file, work_dir, rails_root, log)

    sweeper.sweep()
  end

  desc "Send Test Exception to getexceptional.com"

  task :test do
    require File.join(File.dirname(__FILE__), '/utils/rake_dir_tools')
    require File.join(File.dirname(__FILE__), '..', 'exceptional')
            
    environment = ENV['environment']

    if environment.nil?
      environment = 'production'
    end

    STDOUT.puts "Environment '#{environment}'"
    rails_root = Exceptional::Utils::RakeDirTools.get_rails_root
    STDOUT.puts "RAILS_ROOT #{rails_root}"  
    
    config_file = Exceptional::Utils::RakeDirTools.get_config_file
    STDOUT.puts "Exceptional config_file #{config_file}"    
        
    Exceptional.bootstrap(environment, rails_root, config_file)

    if !Exceptional.api_key_validate
      STDERR.puts "Error Authenticating Exceptional API-Key #{Exceptional.api_key}"
    else

      class Exceptional::TestException < StandardError; end

      if Exceptional.catch(Exceptional::TestException.new('Test Exception'))
        STDOUT.puts "Sending test exception successful [ #{environment} ]"
      else
        STDERR.puts "Sending test exception successful [ #{environment} ]"
      end
    end

  end
end
