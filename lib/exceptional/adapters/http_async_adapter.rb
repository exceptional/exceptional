require File.dirname(__FILE__) + '/../utils/http_utils'

module Exceptional
  module Adapters

    class HttpAsyncAdapterException < StandardError; end

    class HttpAsyncAdapter

      include Exceptional::Utils::HttpUtils

      def publish_exception(json_data)
        begin
          # Temporarily create a Thread just for this send
          Thread.new {
            http_call_remote(:errors, json_data)
          }
        rescue Exception => e
          raise HttpAsyncAdapterException.new e.message
        end
      end

    end
  end
end
