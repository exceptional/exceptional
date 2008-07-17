require 'exceptional/agent'

logger = RAILS_DEFAULT_LOGGER
config_file = "#{RAILS_ROOT}/config/exceptional.yml"

begin 
  # Load exceptional config file
  config = YAML::load(File.open(config_file))

  agent = Exceptional::Agent.instance
  agent.start(config)
  
  mongrel = nil;
  if defined?(Mongrel)
    ObjectSpace.each_object(Mongrel::HttpServer) do |mongrel_instance|
      agent.log.info("Multiple Mongrels in the Ruby VM? This might not work!") if mongrel  
      mongrel = mongrel_instance
    end
  end

  if RAILS_ENV == 'production'
    ActionController::Base.class_eval do
      include Exceptional::Rescuer
    end
  end

rescue Errno::ENOENT => e
  logger.fatal "*"*78
  logger.fatal "** WARNING: Exceptional config file not found (RAILS_ROOT/config/exceptional.yml)."
  logger.fatal "*"*78
rescue Exception => e
  logger.fatal "*"*78
  logger.fatal "** Exceptional plugin not loaded."
  logger.fatal "** " + e
  logger.fatal e.backtrace.join
  logger.fatal "*"*78
end
