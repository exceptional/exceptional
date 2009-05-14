# require all adapters
Dir.glob(File.join(File.dirname(__FILE__), 'adapters/*_adapter.rb')).each {|f| require f }


module Exceptional   #:nodoc:

  #
   # = Exceptional Publishing Adapters
   #
   # The mechamism used to publish exception data to the Exceptional server is pluggagle. These adapters are implemented in Adapter 
   # classes
   #
   # ==== HttpAdapter
   # The HttpAdapter dispatches exception data to the Exceptional server over HTTP(s) within the single application thread.    
   #
   # This is the default adapter and is considered suitable for most applications
   #
   # ==== HttpAsyncAdapter
   # The HttpAsyncAdapter dispatches the exception data to the Exceptional server over HTTP(s) but within a new temporary Thread, meaning the application
   # will continue without the overhead of the network call to the exceptional server. 
   #
   # This adapter is suitable for performance sensitive applicaitons whose deployment server permits temporary thread creation 
   #
   #
   # ==== FileAdapter
   # The FileAdapter does not publish the exception directly to the Exceptional server, but rather stores the exception data on the local filesystem
   #
   # A cron job can then be used to publish this exception data to the exceptional server as part of a batch process
   #
   # By Default the exceptional data is stored in .json files within the RAILS_ROOT/tmp/exceptional directory (configured via the work_dir config parameter)
   #
   # A Rake task 'rake exceptional:file_sweeper' is run to sweep the work_dir and publish any exception files to the exceptional server
   #
   # The rake task will delete the exception data when the data is successfully published.
   #
   #


  module AdapterManager

 
    ADAPTER_MODULE_PREFIX = "Exceptional::Adapters::"

    class AdapterManagerException < StandardError    #:nodoc:
    end

    def post_exception(data)
      Exceptional.api_key_validate if !Exceptional.api_key_validated?
            
      adapter.publish_exception(data)
    end

    protected

    def adapter
      @adapter || @adapter = load_adapter
    end

    private

    def load_adapter
      begin
        adapter_name = ADAPTER_MODULE_PREFIX + Exceptional.adapter_name?
        eval(adapter_name).new # Instantiate adapter
      rescue NameError => e
        raise AdapterManagerException.new("Invalid Adapter Name #{Exceptional.adapter_name?}")
      end
    end
  end
end