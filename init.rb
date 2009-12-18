require 'exceptional'

unless Object.const_defined?(:JSON)
  begin
    require 'json'
  rescue LoadError
    begin
      require 'json-ruby'
    rescue LoadError
      require 'json_pure'
    end
  end
end
unless Object.const_defined?(:JSON)
  raise "Could not load json gem; make sure you install one of json_pure, json-ruby, or the C-based json gem."
end

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
    Exceptional::Startup.announce
    require File.join('exceptional', 'integration', 'rails')
  rescue => e
    STDERR.puts "Problem starting Exceptional Plugin. Your app will run as normal."
    STDERR.puts e
  end
end