module Exceptional
  module Integration
    class ExceptionalTestException <StandardError;
    end

    def self.test
      data = Exceptional::ExceptionData.new(ExceptionalTestException.new, 'Test exception')
      unless Exceptional::Remote.error(data)
        puts "Problem sending exception to Exceptional. Check your API key."
      else
        puts "Exception sent successfully."
      end
    end
  end
end


