module Exceptional
  class Catcher
    class << self
      def handle(exception, controller, request, params)
        ExceptionData.new(exception, controller, request, params)
      end
    end
  end
end