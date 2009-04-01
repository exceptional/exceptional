require File.dirname(__FILE__) + '/../utils/http_utils'

module Exceptional
  module Adapters
    module HttpAdapter

      class HttpAdapterException < StandardError; end

      include Exceptional::Utils::HttpUtils

      def publish_exception(json_data)
        http_call_remote(:errors, json_data)
      end
    end
  end
end
