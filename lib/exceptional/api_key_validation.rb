require 'exceptional/utils/http_utils'

module Exceptional
  module APIKeyValidation
   
    include Exceptional::Utils::HttpUtils
    
    
    # authenticate with getexceptional.com
    # returns true if the configured api_key is registered and can send data
    # otherwise false

    def api_key_validate

      return @api_key_validated if @api_key_validated

      if Exceptional.api_key.nil?
        raise Exceptional::Config::ConfigurationException.new("API Key must be configured")
      end

      begin
        # TODO No data required to api_key_validate, send a nil string? hacky
        api_key_validated = http_call_remote(:authenticate, "")
        
        @api_key_validated = api_key_validated =~ /true/ ? true : false
      rescue
        @api_key_validated = false
      ensure
        return @api_key_validated
      end
    end

    def api_key_validated?
      @api_key_validated || false
    end
    
  end
end