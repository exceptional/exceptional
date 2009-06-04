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
        Exceptional.log! "Authenticating for key #{Exceptional.api_key}", 'debug'
        
        if (http_call_remote(:authenticate, "") =~ /true/)
          Exceptional.log! "Authentication successful", 'debug'
          @api_key_validated = create_auth_file
        else 
          Exceptional.log! "Authentication failed", 'debug'
          @api_key_validated = false
        end
      rescue Exception => e
        Exceptional.log! "Error authenticaing Exceptional #{e.message} #{e.backtrace}", 'error'
        @api_key_validated = false
      end
    end

    def api_key_validated?
      @api_key_validated || valid_auth_file
    end
        
    private 
    
    def valid_auth_file(dir = Exceptional.tmp_dir)
      Exceptional.log! "Checking for Valid Auth File #{File.expand_path(File.join(dir, AUTHENTICATED_FILE_NAME))}", 'debug'
      
      if FileTest.exists?(File.join(dir, AUTHENTICATED_FILE_NAME))
        auth_file = File.open(File.join(dir, AUTHENTICATED_FILE_NAME))
        
        Exceptional.log! "Auth file found with timestamp #{auth_file.mtime}", 'debug'
          
        # If the auth file is more than 1 day old then re-authenticate
        
        if ((Time.now - auth_file.mtime).to_i > 60*60*24)
          Exceptional.log! "Auth file greater than 1 day old fail", 'debug'
          return false
        else
          Exceptional.log! "Auth file less than 1 day old success", 'debug'
          return true
        end
        
      else
        Exceptional.log! "No Auth File found", 'debug'
        #The auth-file does not exist so (re)authenticate
        return false          
      end
    end        
    
    def create_auth_file(dir = Exceptional.tmp_dir)
      begin
        ensure_directory(dir, Exceptional.log)      

        File.open(File.join(dir, AUTHENTICATED_FILE_NAME), 'w') {|f|
          f.write(Exceptional.api_key)
        }
      
        Exceptional.log! "Created Auth File #{File.expand_path(File.join(dir, AUTHENTICATED_FILE_NAME))}", 'debug'
        return true
      end
    rescue Exception => e
      Exceptional.log! "Errror creating auth file #{e.message} #{e.backtrace}", 'error'
      return false
    end
  end
end