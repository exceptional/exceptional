require 'exceptional/utils/http_utils'
require 'exceptional/utils/file_utils'
require 'date'

module Exceptional
  module APIKeyValidation #:nodoc:
    
    include Exceptional::Utils::HttpUtils
    include Exceptional::Utils::FileUtils
    
    AUTHENTICATED_FILE_NAME = '.exceptional-authenticated'
    # authenticate with getexceptional.com
    # returns true if the configured api_key is registered and can send data
    # otherwise false

    def api_key_validate

      return true if api_key_validated?

      if Exceptional.api_key.nil?
        raise Exceptional::Config::ConfigurationException.new("Exceptional API Key must be configured")
      end

      begin
        Exceptional.to_log 'debug', "Authenticating for key #{Exceptional.api_key}"
        # TODO No data required to api_key_validate, send a nil string? hacky
        valid = (http_call_remote(:authenticate, "") =~ /true/) ? true : false
        
        Exceptional.to_log 'debug', "Authentication Successful #{valid}"
        if valid
          @api_key_validated = create_auth_file
        else 
          @api_key_validated = false
        end
      rescue Exception => e
        Exceptional.log! 'error', "Error authenticaing Exceptional #{e.message}"
        @api_key_validated = false
      end
      
      return @api_key_validated
    end

    def api_key_validated?
      @api_key_validated || valid_auth_file
    end
    
    
    private 
    
    def valid_auth_file
      Exceptional.to_log 'debug', "Checking for Valid Auth File #{File.expand_path(File.join(Exceptional.tmp_dir, AUTHENTICATED_FILE_NAME))}"
      
      if FileTest.exists?(File.join(Exceptional.tmp_dir, AUTHENTICATED_FILE_NAME))
        auth_file = File.open(File.join(Exceptional.tmp_dir, AUTHENTICATED_FILE_NAME))
        Exceptional.to_log 'debug', "Auth file found #{auth_file.mtime}"
          
        # If the auth file is more than 1 day old then re-authenticate
        ((Date.today - auth_file.mtime) > 1) ? false: true
      else
        Exceptional.to_log 'debug', "No Auth File found"  
        #The auth-file does not exist so authenticate
          false          
      end
    end        
    
    def create_auth_file
      begin
        ensure_tmp_directory(Exceptional.log)      
      
        auth_file = File.join(Exceptional.tmp_dir, AUTHENTICATED_FILE_NAME)

        File.open(auth_file, 'w') {|f|
          f.write(Exceptional.api_key)
        }
      
        Exceptional.to_log 'debug', "Created Auth File #{File.expand_path(auth_file)}"
        auth_file.close        
      
        return true
      end
    rescue Exception => e
      Exceptional.log! 'error', "Error creating auth file #{File.expand_path(auth_file)} #{e.message}"      
      return false
    end
  end
end