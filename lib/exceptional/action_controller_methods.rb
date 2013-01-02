module Exceptional
  module ActionControllerMethods
    def rescue_with_exceptional(exception)
      unless exception_handled_by_rescue_from?(exception)
        Exceptional::Catcher.handle_with_controller(exception, self, request)
        Exceptional.context.clear!
      end
    end

    private

    def exception_handled_by_rescue_from?(exception)
      respond_to?(:handler_for_rescue) && handler_for_rescue(exception)
    end
  end
end 
