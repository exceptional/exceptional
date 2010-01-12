require 'rubygems'
require 'exceptional'

module Rack
  class Exceptional
    def initialize(app, exceptional_config = "exceptional.yml")
      @app = app
      ::Exceptional::Config.load(exceptional_config)
    end    
    
    def call(env)
      ::Exceptional.rescue_and_reraise do
        status, headers, body =  @app.call(env) 
      end      
    end
  end
end