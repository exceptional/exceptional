require File.dirname(__FILE__) + '/adapters/http_adapter'

module Exceptional
  module AdapterManager

    include Exceptional::Adapters::HttpAdapter


    def post_exception(data)
      if !api_key_validated?
        api_key_validate
      end

      publish_exception(data)
    end

  end
end