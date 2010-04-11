require 'rubygems'
require 'rack'

module Rack  
  class RailsExceptional    

    def initialize(app)
      @app = app
    end    
    
    def call(env)
      begin
        status, headers, body =  @app.call(env)
      rescue Exception => e                                                               
        puts ">>>#{env['action_controller.instance']}"
        ::Exceptional::Catcher.handle_with_controller(e,env['action_controller.instance'], Rack::Request.new(env))
        raise
      end
    end
  end
end
