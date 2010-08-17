module Exceptional
  class AlertData < ExceptionData
    # Overwrite backtrace, since it is irrelevant
    def extra_data
      {
        'exception' => {
          'exception_class' => @exception.class.to_s,
          'message' => @exception.message,
          'backtrace' => "",
          'occurred_at' => Time.now
        }
      }
    end
  end
end