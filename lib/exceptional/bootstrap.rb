module Exceptional
  module Bootstrap #:nodoc:  

    def bootstrap(environment, application_root)
      begin
        Exceptional.setup_config(environment, File.join(application_root,"config", "exceptional.yml"), application_root)
        Exceptional.setup_log(File.join(application_root, "log"), Exceptional.log_level?)

        if Exceptional.enabled?
          
          if Exceptional.api_key_validate            
            if Exceptional.adapter.bootstrap
              require File.join('exceptional', 'integration', 'rails')
              Exceptional.to_log "Exceptional plugin enabled #{adapter.name}" 
            else
              raise Exceptional::ConfigException "Unable to boostrap adapter"
            end
          else
            Exceptional.log! "Exceptional plugin not api_key_validated, check your API Key"
          end
        end
      rescue Exception => e
        # Should these be writing to Exceptional.log! ?
        Exceptional.log! "Exceptional Plugin disabled. #{e.message}"
      end
    end
  end
end