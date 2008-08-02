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
    
    def prepare_connection_xml
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.agent do |a|
        a.hostname @local_host
        a.port @local_port
        a.pid $$
        a.started_at @start_time
        a.rails_root RAILS_ROOT
        a.environment @environment.to_s
      end
      xml.target!
    end
    
    def prepare_disconnection_xml
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.agent do |a|
        a.agent_id @agent_id
        a.stopped_at Time.now.to_s
      end
      xml.target!
    end
    
    def prepare_exception_xml(exception,controller,request)
      xml = Builder::XmlMarkup.new
      xml.instruct! 
      xml.error do |e|
        e.agent_id @agent_id
        e.controller_name controller.controller_name
        e.action_name controller.action_name
        e.error_class exception.class.name
        e.message exception.message
        e.backtrace exception.backtrace.join("\n")
        e.occurred_at Time.now.to_s
        e.rails_root RAILS_ROOT
        e.url "#{request.protocol}#{request.host}#{request.request_uri}"
        
        e.environment do |env|
          request.env.each do |k,v|
            env.tag! k.downcase.to_sym, v.to_s.strip
          end
        end

        e.session do |sess|
          request.session.instance_variables.each do |v|
            next if v =~ /db/
            # can not haz @ in an xml tag
            var = v.sub("@","")
            sess.tag! var, request.session.instance_variable_get(v)
          end
        end
        
        e.parameters filtered_params(request.parameters).inspect
        
      end
      xml.target!
    end

  end
end