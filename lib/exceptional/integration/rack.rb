require 'rubygems'
require 'rack'

module Rack  
  class Exceptional    

    def initialize(app, api_key = nil)
      @app = app
      if api_key.nil?
        exceptional_config = "config/exceptional.yml"
        ::Exceptional::Config.load(exceptional_config)
      else
        ::Exceptional.configure(api_key)
      end
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
