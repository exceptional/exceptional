task :packagegem do
  begin
    require 'echoe'

    Echoe.new('exceptional', '0.0.1') do |p|
      p.rubyforge_name = 'exceptional'
      p.summary      = "Exceptional is the core Ruby library for communicating with http://getexceptional.com (hosted error tracking service)"
      p.description  = "Exceptional is the core Ruby library for communicating with http://getexceptional.com (hosted error tracking service)"
      p.url          = "http://getexceptional.com/"
      p.author       = ['David Rice']
      p.email        = "david@contrast.ie"
      p.dependencies = ["json"]
    end

  rescue LoadError => e
    puts "You are missing a dependency required for meta-operations on this gem."
    puts "#{e.to_s.capitalize}."
  end
end

# add spec tasks, if you have rspec installed
begin
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new("spec") do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ['--color']
  end

  task :test do
    Rake::Task['spec'].invoke
  end

  Spec::Rake::SpecTask.new("coverage") do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ['--color']
    t.rcov = true
    t.rcov_opts = ['--exclude', '^spec,/gems/']
  end

  namespace :exceptional do
    require File.join(File.dirname(__FILE__), 'lib/exceptional')

    EXCEPTIONAL_CONFIG_FILE = "exceptional.yml"

    desc "Install Exceptional Plugin"
    task :rails_install do
      require 'ftools'
      require File.join(File.dirname(__FILE__), 'lib/exceptional/utils/rake_dir_tools')

      key = ENV['api_key']

      # Add Usage
      if key.nil?
        STDERR.puts "Usage 'rake install api_key=[API_KEY]"
        STDERR.puts " *** Exceptional Installation Failed "
        return
      end

      rails_root = Exceptional::Utils::RakeDirTools.get_rails_root

      exceptional_config_template = File.join(File.dirname(__FILE__), EXCEPTIONAL_CONFIG_FILE)

      config_dir = Exceptional::Utils::RakeDirTools.get_config_dir

      if File.copy(exceptional_config_template, config_dir, true)
        new_config_file = File.join(config_dir, EXCEPTIONAL_CONFIG_FILE)

        s = 'PASTE_YOUR_API_KEY_HERE'
        r = key

        lines = []
        File.open(new_config_file, "r"){|f| lines = f.readlines }
        lines = lines.inject([]){|l, line| l << line.gsub(s, r)}
        File.open(new_config_file, "w"){|f| f.write(lines) }


        Exceptional.setup_config("test", new_config_file)

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
end
