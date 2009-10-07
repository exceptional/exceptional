module Exceptional
  class ExceptionData
    def initialize(exception, controller=nil, request=nil, params=nil)
      @exception = exception
    end

    def to_hash
      hash = {
          'exception' => {
              'exception_class' => @exception.class.to_s,
              'exception_message' => @exception.message,
              'exception_backtrace' => @exception.backtrace
          }
      }
      hash
    end
   end
end