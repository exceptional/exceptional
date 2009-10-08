require 'exceptional'

begin
  config_file = "#{RAILS_ROOT}/config/exceptional.yml"
  Exceptional::Config.load(RAILS_ROOT, RAILS_ENV, config_file)
  Exceptional::Startup.announce
  require File.join('exceptional', 'integration', 'rails')
rescue => e
  STDERR.puts "Problem starting Exceptional Plugin. Your app will run as normal."
  STDERR.puts e
  STDERR.puts e.backtrace
end
