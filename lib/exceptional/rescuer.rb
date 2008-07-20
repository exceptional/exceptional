module Exceptional
  
  module Rescuer

    def rescue_action_in_public(exception)
      response_code = response_code_for_rescue(exception)
      unless response_code == :notfound
        begin
          Exceptional::Agent.instance.queue_to_send(exception, self, request)
        rescue Exception => exception
          if logger
            logger.fatal "Exceptional fail! Sorry, an exception occurred while trying to log your exception. How Ironic."
            log_error(exception)
          end
        end
      end
      
      # Render appropriate error file in Rails 2.0.x
      if self.respond_to?(:render_optional_error_file)      
        render_optional_error_file response_code_for_rescue(exception)
      else # Render appropriate error file in Rails 1.2.x
        case exception
          when ActiveRecord::RecordNotFound, ActionController::RoutingError, ActionController::UnknownAction
            render_text(IO.read(File.join(RAILS_ROOT, 'public', '404.html')), "404 Not Found")
        else # TODO Rails 1.1.x does not have a 500.html
          render_text(IO.read(File.join(RAILS_ROOT, 'public', '500.html')), "500 Internal Error")
        end
      end
    end
  
  end
  
end
