module Exceptional
  class Catcher
    class << self
      def handle(exception, controller, request)
        data = ExceptionData.new(exception, controller, request)
        Remote.error(data.to_json)
      end
    end
  end
end