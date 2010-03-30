require 'exceptional'

# If old plugin still installed then we don't want to install this one.
# In production environments we should continue to work as before, but in development/test we should
# advise how to correct the problem and exit
if (defined?(Exceptional::VERSION::STRING) rescue nil) && %w(development test).include?(RAILS_ENV)
  message = %Q(
  ***********************************************************************
  You seem to still have an old version of the Exceptional plugin installed.
  Remove it from /vendor/plugins and try again.
  ***********************************************************************
  )
  puts message
  exit -1
else
  begin
    Exceptional::Config.load(File.join(RAILS_ROOT, "/config/exceptional.yml"))
    require File.join('exceptional', 'integration', 'rails')
    require File.join('exceptional', 'integration', 'dj')
  rescue => e
    STDERR.puts "Problem starting Exceptional Plugin. Your app will run as normal."
    STDERR.puts e
  end
end