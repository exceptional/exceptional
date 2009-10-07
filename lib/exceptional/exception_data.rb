module Exceptional
  class ExceptionData
    def initialize(exception, controller=nil, request=nil, params=nil)
      @exception = exception
    end

    def to_hash
      hash = {
        'client' => {
          'name' => Exceptional::CLIENT_NAME,
          'version' => Exceptional::VERSION
          },
        'exception' => {
          'exception_class' => @exception.class.to_s,
          'message' => @exception.message,
          'backtrace' => @exception.backtrace,
          'occurred_at' => Time.now.strftime("%Y%m%d %H:%M:%S %Z")
        }
      }
      hash
    end

    def to_json
      to_hash.to_json
    end
  end
end