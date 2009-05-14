require 'exceptional/utils/file_sweeper'
require 'exceptional/adapters/base_adapter'

module Exceptional
  module Adapters  #:nodoc:

    class HttpAsyncAdapterException < StandardError    #:nodoc:
    end

    class HttpAsyncAdapter < BaseAdapter   #:nodoc:

      include Exceptional::Utils::HttpUtils

      def publish_exception(json_data)
        begin

          # Temporarily create a Thread just for this send
          Thread.new {
            begin
              http_call_remote(:errors, json_data)
            rescue Exception => e
              Exceptional.log! e.message
            end
          }
        rescue Exception => e
          raise HttpAsyncAdapterException.new(e.message)
        end
      end

    end
  end
end
