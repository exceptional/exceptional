namespace :exceptional do
  require File.join(File.dirname(__FILE__), '../lib/exceptional')

  EXCEPTIONAL_CONFIG_FILE = "exceptional.yml"

  desc "Install Exceptional Plugin"
  task :rails_install do
    require 'ftools'
    require File.join(File.dirname(__FILE__), '../lib/exceptional/utils/rake_dir_tools')

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
end
