module Exceptional
  class Catcher

    class << self

      def handle_with_controller(exception, controller=nil, request=nil)

        if Config.should_send_to_api? &&
            !ignore?(exception, request)

          data = ControllerExceptionData.new(exception, controller, request)
          Sender.error(data)
        else
          raise exception
        end

      end

      def handle_with_rack(exception, environment, request) 

        if Config.should_send_to_api?
          data = RackExceptionData.new(exception, environment, request)
          Sender.error(data)
        else
          raise exception
        end

      end

      def handle(exception, name=nil)
        # TODO: duplications, duplications everywhere

        if Config.should_send_to_api?
          data = ExceptionData.new(exception, name)
          Sender.error(data)
        else
          raise exception
        end

      end

      def ignore?(exception, request)
        ignore_class?(exception) || ignore_user_agent?(request)
      end

      def ignore_class?(exception)
        Config.ignore_exceptions.flatten.any? do |exception_class|
          exception_class === exception.class.to_s
        end
      end

      def ignore_user_agent?(request)
        Config.ignore_user_agents.flatten.any? do |user_agent|
          user_agent === request.user_agent.to_s
        end
      end
    end
  end
end
