require File.dirname(__FILE__) + '/utils/http_utils'

module Exceptional
  module Remote

    include Exceptional::Utils::HttpUtils

    # authenticate with getexceptional.com
    # returns true if the configured api_key is registered and can send data
    # otherwise false
    def post_exception(data)
      if !authenticated?
        authenticate
      end

      http_call_remote(:errors, data)
    end

  end
end