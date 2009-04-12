module Exceptional
  module Adapters  
    class BaseAdapter #:nodoc:

      def bootstrap
        return true
      end
      
      def name
        return self.class
      end
    end
  end
end