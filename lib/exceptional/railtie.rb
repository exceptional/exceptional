require 'exceptional'
require 'rails'

module Exceptional
  class Railtie < Rails::Railtie

    initializer "exceptional.middleware" do |app|

      if File.exist?(File.join(Rails.root, "/config/exceptional.yml"))
        Exceptional::Config.load(File.join(Rails.root, "/config/exceptional.yml"))
      else
        # On Heroku config is loaded via the ENV
      end

      if Exceptional::Config.should_send_to_api?
        Exceptional.logger.info("Loading Exceptional #{Exceptional::VERSION} for #{Rails::VERSION::STRING}")
        app.config.middleware.use "Rack::RailsExceptional"
      end
    end
  end
end
