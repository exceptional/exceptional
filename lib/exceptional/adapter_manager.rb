require File.dirname(__FILE__) + '/adapters/http_adapter'

# require all adapters
Dir.glob(File.join(File.dirname(__FILE__), 'adapters/*.rb')).each {|f| require f }


module Exceptional
  module AdapterManager

    ADAPTER_MODULE_PREFIX = "Exceptional::Adapters::"


    class AdapterException < StandardError; end
    
    def adapter
      begin
        adapter_name = ADAPTER_MODULE_PREFIX + Exceptional.adapter_name
        @adapter || @adapter = eval(adapter_name).new # Instantiate adapter
      rescue Exception => e
        raise AdapterException.new e.message
      end
    end

    def post_exception(data)
      if !api_key_validated?
        api_key_validate
      end

      adapter.publish_exception(data)
    end
  end
end
