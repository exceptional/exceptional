module Exceptional
  module Bootstrap

    # called from init.rb
    def bootstrap(environment, application_root)
      begin
        setup_config(environment, File.join(application_root,"config", "exceptional.yml"))
        setup_log(File.join(application_root, "log"), log_level)

        if enabled?
          if api_key_validate
            if !adapter.bootstrap # Change to setup/bootstrap adapter
              require File.join('exceptional', 'integration', 'rails')
            end            
          else
            STDERR.puts "Exceptional plugin not api_key_validated, check your API Key"
          end
        end
      rescue Exception => e
        # Should these be writing to Exceptional.log! ?
        STDERR.puts e.message
        STDERR.puts "Exceptional Plugin disabled. #{e.message}"
      end
    end
  end
end
