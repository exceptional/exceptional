module Exceptional
  class Catcher
    class << self
      def handle(exception, controller=nil, request=nil)
        data = ExceptionData.new(exception, controller, request)
        Remote.error(data.to_json)
      end
    end
  end
end