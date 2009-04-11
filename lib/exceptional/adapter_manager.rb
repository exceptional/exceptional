# require all adapters
Dir.glob(File.join(File.dirname(__FILE__), 'adapters/*_adapter.rb')).each {|f| require f }


module Exceptional
  module AdapterManager  #:nodoc:

    ADAPTER_MODULE_PREFIX = "Exceptional::Adapters::"

    class AdapterManagerException < StandardError    #:nodoc:
    end

    def adapter
      @adapter || @adapter = load_adapter
    end

    def post_exception(data)
      if !api_key_validated?
        api_key_validate
      end

      adapter.publish_exception(data)
    end

    protected

    def load_adapter
      begin
        adapter_name = ADAPTER_MODULE_PREFIX + Exceptional.adapter_name
        eval(adapter_name).new # Instantiate adapter
      rescue NameError => e
        raise AdapterManagerException.new "Invalid Adapter Name #{Exceptional.adapter_name}"
      end
    end
  end
end
