require 'exceptional/utils/http_utils'
require 'exceptional/adapters/base_adapter'

module Exceptional
  module Adapters  #:nodoc:

    class HttpAdapterException < StandardError    #:nodoc:
    end

    class HttpAdapter < BaseAdapter   #:nodoc:

      include Exceptional::Utils::HttpUtils

      def publish_exception(json_data)
        begin
          http_call_remote(Exceptional.remote_host, Exceptional.remote_port, Exceptional.api_key, Exceptional.ssl_enabled?, :errors, json_data, Exceptional.log)
        rescue Exception => e
          raise HttpAdapterException.new(e.message)
        end
      end
    end
  end
end
