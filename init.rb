require 'exceptional'

def to_stderr(s)
  STDERR.puts "** [Exceptional] " + s
end

config_file = File.join(RAILS_ROOT,"/config/exceptional.yml")

begin 
  Exceptional.application_root = RAILS_ROOT
  Exceptional.environment = RAILS_ENV
  Exceptional.load_config(config_file)
  
  if Exceptional.enabled?
    if Exceptional.authenticate
      Exceptional.setup_log
      require File.join('exceptional', 'integration', 'rails')
      Exceptional.log_config_info
    else  
      Exceptional.log! "Plugin not authenticated, check your API Key"
      Exceptional.log! "Disabling Plugin."
    end
  end
rescue Exception => e
  to_stderr e
  to_stderr "Plugin disabled."
end
