module Exceptional
  module Integration
    class ExceptionalTestException <StandardError;
    end

    def self.test
      data = Exceptional::ExceptionData.new(ExceptionalTestException.new)
      Exceptional::Remote.error(data.to_json)
    end
  end
end


