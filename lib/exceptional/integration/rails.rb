if defined? ActionController

module ActionController
  class Base
    
    def rescue_action_with_exceptional(exception)
      unless respond_to?(:handler_for_rescue) && handler_for_rescue(exception) # if there's handler defined with rescue_from() do not call Exceptional
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