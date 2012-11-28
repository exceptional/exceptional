module Exceptional
  class Catcher
    class << self
      def handle_with_controller(exception, controller=nil, request=nil)
        if Config.should_send_to_api? &&
            !ignore?(exception, request)

          data = ControllerExceptionData.new(exception, controller, request)
          Remote.error(data)
        else
          raise exception
        end
      end
      
      # unspeced
      def handle_with_rack(exception, environment, request) 
        if Config.should_send_to_api?
          data = RackExceptionData.new(exception, environment, request)
          Remote.error(data)
        else
          raise exception
        end
      end

      # unspeced
      def handle(exception, name=nil)
        if Config.should_send_to_api?
          data = ExceptionData.new(exception, name)
          Remote.error(data)
        else
          raise exception
        end
      end

      def ignore?(exception, request)
        ignore_class?(exception) || ignore_user_agent?(request)
      end

      def ignore_class?(exception)
        Config.ignore_exceptions.any? do |exception_class|
          exception_class === exception.class
        end
      end

      def ignore_user_agent?(request)
        Config.ignore_user_agents.any? do |user_agent|
          user_agent === request.user_agent
        end
      end
    end
  end
end
