require 'rubygems'
require 'rack'

module Rack  
  class RailsExceptional    

    def initialize(app)
      @app = app
    end    
    
    def call(env)
      begin
        body = @app.call(env)
      rescue Exception => e
        ::Exceptional::Catcher.handle_with_controller(e,env['action_controller.instance'], Rack::Request.new(env))
        raise
      end

      if env['rack.exception']
        ::Exceptional::Catcher.handle_with_controller(env['rack.exception'],env['action_controller.instance'], Rack::Request.new(env))
      end

      body
    end      
  end
end
