require 'exceptional/agent'

logger = RAILS_DEFAULT_LOGGER
Exceptional::Agent.api_key = nil
config_file = "#{RAILS_ROOT}/config/exceptional.yml"
load_error = nil

if RAILS_ENV == 'production'
  ActionController::Base.class_eval do
    include Exceptional::Rescuer
  end
end

mongrel = nil;
if defined?(Mongrel)
  ObjectSpace.each_object(Mongrel::HttpServer) do |mongrel_instance|
    agent.log.info("Multiple Mongrels in the Ruby vm? this might not work!") if mongrel  
    mongrel = mongrel_instance
  end
end

if FileTest.exists?(config_file)
  # Load exceptional config file
  config = YAML::load(File.open(config_file))
  Exceptional::Agent.api_key = config['api-key']
else
  load_error = "WARNING: Exceptional config file not found (RAILS_ROOT/config/exceptional.yml)"
end

logger.fatal "*"*78
unless load_error 
  logger.fatal "** Exceptional plugin loaded"
  logger.fatal "** API key: " + Exceptional::Agent.api_key.inspect
  logger.fatal "** Mongrel (port): " + mongrel.port.to_s if mongrel
else
  logger.fatal "** Exceptional plugin not loaded"
  logger.fatal "** " + load_error 
end
logger.fatal "*"*78
