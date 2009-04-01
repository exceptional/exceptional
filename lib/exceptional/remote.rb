require File.dirname(__FILE__) + '/adapters/http_adapter'

module Exceptional
  module Remote

    include Exceptional::Adapters::HttpAdapter

    # authenticate with getexceptional.com
    # returns true if the configured api_key is registered and can send data
    # otherwise false
    def post_exception(data)
      if !api_key_validated?
        api_key_validate
      end

      publish_exception(data)
    end

  end
end