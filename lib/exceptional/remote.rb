module Exceptional
  class Remote
    class << self
      def announce
        # post to /announcements
      end

      def submit_error
        # post to /errors
      end
    end
  end
end