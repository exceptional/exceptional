module Exceptional
  class Catcher
    class << self
      def handle(exception, controller, request, params)
        data = ExceptionData.new(exception, controller, request, params)
        Remote.error(data.to_json)
      end
    end
  end
end