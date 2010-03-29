module Exceptional
  module Integration
    class ExceptionalTestException <StandardError;
    end

    def self.test
      begin
        raise ExceptionalTestException.new, 'Test exception'
      rescue Exception => e
        unless Exceptional::Remote.error(Exceptional::ExceptionData.new(e, "Test Exception"))
          puts "Problem sending exception to Exceptional. Check your API key."
        else
          puts "Test Exception sent. Please login to http://getexceptional.com to see it!"
        end
      end
    end
  end
end


