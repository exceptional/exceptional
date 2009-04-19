module Exceptional #:nodoc:
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 0
    TINY  = 2
 
    STRING = [MAJOR, MINOR, TINY].join('.')
    
    def VERSION.to_s
      [MAJOR, MINOR, TINY].join('.')
    end
  end
end