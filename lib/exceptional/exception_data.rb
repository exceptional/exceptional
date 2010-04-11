require 'digest/md5'

module Exceptional
  class ExceptionData
    def initialize(exception, name=nil)
      @exception = exception
      @name = name
    end

    def to_hash
      hash = ::Exceptional::ApplicationEnvironment.to_hash(framework)
      hash.merge!({
        'exception' => {
          'exception_class' => @exception.class.to_s,
          'message' => @exception.message,
          'backtrace' => @exception.backtrace,
          'occurred_at' => Time.now
        }
      })
      hash.merge!(extra_stuff)
      hash.merge!(context_stuff)
      self.class.sanitize_hash(hash)
    end

    def extra_stuff
      { 'rescue_block' => { 'name' => @name} }
    end

    def context_stuff
      context = Thread.current[:exceptional_context]
      (context.nil? || context.empty?) ? {} : {'context' => context}
    end

    def to_json
      begin
        to_hash.to_json
      rescue NoMethodError
        begin
          require 'json'
          return to_hash.to_json
        rescue StandardError
          raise StandardError.new("You need a json gem/library installed to send errors to Exceptional (Object.to_json not defined). \nInstall json_pure, yajl-ruby, json-jruby, or the c-based json gem")
        end
      end
    end
    
    def framework
      nil
    end    

    def uniqueness_hash
      return nil if (@exception.backtrace.nil? || @exception.backtrace.empty?)
      Digest::MD5.hexdigest(@exception.backtrace.join)
    end

    def self.sanitize_hash(hash)
      case hash
        when Hash
          hash.inject({}) do |result, (key, value)|
            result.update(key => sanitize_hash(value))
          end
        when Fixnum, Array, String, Bignum
          hash
        else
          hash.to_s
      end
    rescue
      {}
    end
  end
end