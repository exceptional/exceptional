if defined? ActiveSupport
  
  # Hack to force Rails version prior to 2.0 to use quoted JSON as per the JSON standard... (TODO: could be cleaner!)
  if (defined?(ActiveSupport::JSON) && ActiveSupport::JSON.respond_to?(:unquote_hash_key_identifiers))
    ActiveSupport::JSON.unquote_hash_key_identifiers = false 
  end

end

if defined? ActionController

  module ActionController
    class Base
    
      def rescue_action_with_exceptional(exception)
        # TODO potentially hook onto rescue_without_handler if it exists? would negate need to check handler_for_rescue every time.
        # if there's handler defined with rescue_from() do not call Exceptional
        if !(respond_to?(:handler_for_rescue) && handler_for_rescue(exception))
          params_to_send = (respond_to? :filter_parameters) ? filter_parameters(params) : params
          Exceptional.handle(exception, self, request, params_to_send)
        end
            
        rescue_action_without_exceptional exception
      end
    
      alias_method :rescue_action_without_exceptional, :rescue_action
      alias_method :rescue_action, :rescue_action_with_exceptional
      protected :rescue_action
    end
  end

end