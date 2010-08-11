require 'exceptional'
require 'rails'

module Exceptional
  class Railtie < Rails::Railtie

    Exceptional::Config.load("config/exceptional.yml")

    initializer "exceptional.middleware" do |app|
      if Exceptional::Config.should_send_to_api?
        Exceptional.logger.info("Loading Exceptional for #{Rails::VERSION::STRING}")      
        app.config.middleware.use "Rack::RailsExceptional"
      end
    end
  end
end
