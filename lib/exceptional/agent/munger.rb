module Exceptional::Agent
  
  # Methods for preparing exception data
  module Munger
    
    # Filters any paramters from being sent to Exceptional that have 
    # been specified in the 'filter-parameters' config option.
    # 
    # By default, any parameter matching /password/ will not be sent.
    #
    def filtered_params(params)
      params.each do |k, v|
        params[k] = "[filtered]" if @param_filters.any? do |filter|
          k.to_s.match(/#{filter}/)
        end
      end
    end
    
    def prepare_xml(exception,controller,request)
      xml = Builder::XmlMarkup.new
      xml.instruct! 
      xml.error do |e|
        e.api_key @api_key
        e.controller_name controller.controller_name
        e.action_name controller.action_name
        e.backtrace exception.backtrace.join("\n")
        e.user_ip request.env["HTTP_X_FORWARDED_FOR"] || request.env["REMOTE_ADDR"]
        e.host_ip request.env["HTTP_HOST"]
        e.environment prepare_environment_to_send(request.env)
        e.session prepare_session_to_send(request.session)
        e.request prepare_request_to_send(request)
        e.occurred_at Time.now.to_s
        e.summary "#{controller.controller_name}##{controller.action_name} (#{exception.class}) #{exception.message.inspect}"
      end
      xml.target!
    end

    def prepare_environment_to_send(environment)
      env = ""
      environment.keys.sort.each do |key|
        env << "#{key}:, #{environment[key].to_s.strip}\n"
      end
      env
    end

    def prepare_request_to_send(request)
      req = ""
      req << "URL: #{request.protocol}#{request.env["HTTP_HOST"]}#{request.request_uri}\n"
      req << "Parameters: #{filtered_params(request.parameters).inspect}\n"
      req << "Rails root: #{RAILS_ROOT}"
      req
    end

    def prepare_session_to_send(session)
      ses = ""
      for variable in session.instance_variables
        next if variable =~ /^@db/
        ses << "#{variable}: #{session.instance_variable_get(variable)}\n"
      end
      ses
    end
  end
  
end