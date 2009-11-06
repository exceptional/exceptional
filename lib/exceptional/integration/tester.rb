module Exceptional
  module Integration
    class ExceptionalTestException <StandardError;
    end

    def self.test
      data = Exceptional::ExceptionData.new(ExceptionalTestException.new)
      unless Exceptional::Remote.error(data)
        puts "Problem sending error to Exceptional. Check your api key"
      else
        puts "Exception sent successfully"
      end
    end
  end
end


