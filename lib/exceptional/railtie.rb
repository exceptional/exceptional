require 'exceptional'
require 'rails'

module Exceptional
  class Railtie < Rails::Railtie

    initializer "exceptional.middleware" do |app|
      Exceptional::Config.load(File.join(Rails.root, "/config/exceptional.yml"))

      if Exceptional::Config.should_send_to_api?
        Exceptional.logger.info("Loading Exceptional #{Exceptional::VERSION} for #{Rails::VERSION::STRING}")      
        app.config.middleware.use "Rack::RailsExceptional"
      end
    end
  end
end
