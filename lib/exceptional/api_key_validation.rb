require File.dirname(__FILE__) + '/utils/http_utils'

module Exceptional
  module APIKeyValidation
   
    include Exceptional::Utils::HttpUtils
    
    def authenticate

      return @authenticated if @authenticated

      if Exceptional.api_key.nil?
        raise Exceptional::Config::ConfigurationException.new("API Key must be configured")
      end

      begin
        # TODO No data required to authenticate, send a nil string? hacky
        authenticated = http_call_remote(:authenticate, "")
        
        @authenticated = authenticated =~ /true/ ? true : false
      rescue
        @authenticated = false
      ensure
        return @authenticated
      end
    end

    def authenticated?
      @authenticated || false
    end
    
  end
end