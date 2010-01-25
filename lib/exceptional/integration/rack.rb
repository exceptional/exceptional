require 'rubygems'
require 'rack'

module Rack  
  class Exceptional    

    def initialize(app, exceptional_config = "config/exceptional.yml")
      @app = app
      ::Exceptional::Config.load(exceptional_config)
    end    
    
    def call(env)
      begin
        status, headers, body =  @app.call(env)
      rescue Exception => e
        ::Exceptional::Catcher.handle_with_rack(e,env, Rack::Request.new(env))
        raise(e)
      end
    end
  end
end
