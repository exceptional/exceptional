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
    require 'lib/exceptional'

    EXCEPTIONAL_CONFIG_FILE = "exceptional.yml"
    RELATIVE_RAILS_ROOT = "../../../"
    RELATIVE_RAILS_CONFIG_PATH = RELATIVE_RAILS_ROOT + "config"

    def get_config_dir

      if !ENV['config_dir']
        config_dir = ENV['config_dir']
      else
        config_dir = File.join(File.dirname(__FILE__), RELATIVE_RAILS_CONFIG_PATH)
      end
    end

    def get_config_file
      # Exceptional Config File
      if !ENV['config_file'].nil?
        config_file = ENV['config_file']
      else
        rails_config_dir = get_config_dir

        if !FileTest.directory?(rails_config_dir)
          STDERR.puts "Invalid Config Directory #{rails_config_dir}"
          raise IOError "Exceptional Config File not found #{config_file}"
        end

        config_file = File.join(rails_config_dir, EXCEPTIONAL_CONFIG_FILE)
      end

      if !FileTest.exists?(config_file)
        STDERR.puts "Exceptional Config File not found #{config_file}"
        raise IOError "Exceptional Config File not found #{config_file}"
      end

      return config_file
    end

    def get_work_dir
      # Directory where to look for exception files
      if !ENV['work_dir'].nil?
        work_dir = ENV['work_dir']
      else
        work_dir = File.join(RELATIVE_RAILS_ROOT, '/tmp/exceptional')
      end
    end

    def get_rails_root
      # The application root
      if !ENV['rails_root'].nil?
        rails_root = ENV['rails_root']
      else
        rails_root = File.join(File.dirname(__FILE__), RELATIVE_RAILS_ROOT)
      end
    end

    desc "Install Exceptional Plugin"
    task :rails_install do
      require 'ftools'


      key = ENV['api_key']

      # Add Usage
      if key.nil?
        STDERR.puts "Usage 'rake install api_key=[API_KEY]"
        STDERR.puts " *** Exceptional Installation Failed "
        return
      end

      rails_root = get_rails_root

      exceptional_config_template = File.join(File.dirname(__FILE__), EXCEPTIONAL_CONFIG_FILE)

      if File.copy(exceptional_config_template, get_config_dir, true)
        new_config_file = File.join(get_config_dir, EXCEPTIONAL_CONFIG_FILE)

        s = 'PASTE_YOUR_API_KEY_HERE'
        r = key

        lines = []
        File.open(new_config_file, "r"){|f| lines = f.readlines }
        lines = lines.inject([]){|l, line| l << line.gsub(s, r)}
        File.open(new_config_file, "w"){|f| f.write(lines) }


        Exceptional.setup_config("test", new_config_file, rails_root)

        if !Exceptional.validate
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
      puts "Config File :  #{new_config_file}"
      puts "Key : #{key}"
      puts ""
    end

    desc "Directory Sweeper for the File System Adapter"
    task :file_sweeper do

      require 'logger'
      require 'lib/exceptional/utils/file_sweeper'

      config_file = get_config_file
      work_dir = get_work_dir
      rails_root = get_rails_root

      log_dir = File.join(rails_root, "log")
      Dir.mkdir(log_dir) unless File.directory?(log_dir)

      log_path = File.join(log_dir, "/exceptional_file_sweeper.log")
      log = Logger.new log_path

      sweeper = Exceptional::Utils::FileSweeper.new(config_file, work_dir, rails_root, log)

      sweeper.sweep()
    end
  end
end