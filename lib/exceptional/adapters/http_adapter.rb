require 'exceptional/utils/http_utils'
require 'exceptional/adapters/base_adapter'

module Exceptional
  module Adapters

    class HttpAdapterException < StandardError; end

    class HttpAdapter < BaseAdapter

      include Exceptional::Utils::HttpUtils
      
      def publish_exception(json_data)
        begin
          http_call_remote(:errors, json_data)
        rescue Exception => e
          raise HttpAdapterException.new e.message
        end
      end      
    end
  end
end
