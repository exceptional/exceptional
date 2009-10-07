require 'exceptional'

begin
  setup_config(environment, File.join(application_root,"config", "exceptional.yml"))
  setup_log(File.join(application_root, "log"), log_level)
  config_file = "#{RAILS_ROOT}/config/exceptional.yml"
  Exceptional::Config.load(config_file, RAILS_ENV)
  authenticated = Exceptional::Startup.announce_and_authenticate
  if authenticated
    require File.join('exceptional', 'integration', 'rails')
  else
    STDERR.puts "Exceptional plugin not authenticated, check your API Key"
  end
rescue => e
  STDERR.puts "Problem starting Exceptional Plugin. Your app will run as normal."
  STDERR.puts e
end
