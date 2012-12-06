require "exceptional"
require "json"

require "action_controller"

ENV['RAILS_ENV'] = 'test'


if defined?(ActionDispatch::DebugExceptions)
  # rails 3.2.x
  module ActionDispatch
    class DebugExceptions
      private
      remove_method :stderr_logger
      # Silence logger
      def stderr_logger
        nil
      end
    end
  end
  ActionDispatch::DebugExceptions.send(:include,Exceptional::ExceptionMiddleware)
elsif defined?(ActionDispatch::ShowExceptions)
  # rails 3.0.x && 3.1.x
  module ActionDispatch
    class ShowExceptions
      # silence logger
      def logger() nil; end
    end
  end
  ActionDispatch::ShowExceptions.send(:include,Exceptional::ExceptionMiddleware)
end

def build_app(controller_action, route = "/")
  Rack::Builder.new do
    if defined?(ActionDispatch::PublicExceptions) # Rails 3.2 only
      use ActionDispatch::ShowExceptions, ActionDispatch::PublicExceptions.new("public")
    elsif defined?(ActionDispatch::ShowExceptions)
      use ActionDispatch::ShowExceptions
    end
    if defined?(ActionDispatch::DebugExceptions)
      use ActionDispatch::DebugExceptions
    end
    map "#{route}" do
      run controller_action
    end
  end.to_app
end

def send_request(action_name)
  @request = Rack::MockRequest.env_for("/")
  @app = build_app(@controller.action(action_name))
  begin
  status, headers, body = @app.call(@request)
  rescue
  end
end
