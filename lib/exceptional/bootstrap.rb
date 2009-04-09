module Exceptional
  module Bootstrap


    def bootstrap(environment, application_root)
      begin
        setup_config(environment, File.join(application_root,"config", "exceptional.yml"))
        setup_log(File.join(application_root, "log"), log_level)

        if enabled?
          
          if api_key_validate            
            if adapter.bootstrap
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