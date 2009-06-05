require 'json' unless defined? Rails

module Exceptional    #:nodoc:

# =API
#
# ==== Overview
#
#  The data format we chose to base the API upon is JSON, we chose this for two reasons;
#
#      * It's faster to generate than XML. Not much, but every little helps.
#      * Reduced weight.
#
#  Before sending the data, it should be compressed, again to save on outgoing bandwidth. This adds a slight overhead to the pre-processing of an exception but is worth it for the savings on data size.
#
#  Finally, to ensure no funky goings on. We escape the compressed data. This gives the following flow.
#
#     1. Catch exception
#     2. Prepare JSON
#     3. Compress (using Zlib compression)
#     4. Escape
#     5. Send
#
# ==== Required Exception Data
#
#  There is a minimum of data that is required in an API request for Exceptional to work properly.
#
#      * language (String, e.g. "ruby")
#      * exception_class (String, e.g. "ReallyBadError")
#      * exception_message (String, e.g. "undefined method `this_method_dont_exist' for nil:NilClass")
#      * exception_backtrace (an Array of Strings)
#
# ==== Optional Exception Data
#  The following is all optional data that can be sent to Exceptional, it's used in our Rails plugin.
#
#      * occurred_at (a DateTime, when the exception occurred)
#      * framework (String, e.g. "rails")
#      * controller_name (String, e.g. "SomeBuggyController")
#      * action_name (String, e.g. "buggy_action")
#      * application_root (String, e.g. "/var/www/some_rails_app")
#      * url (String, e.g. "http://buggysite.com/something")
#      * parameters (a Hash)
#      * session (a Hash)
#      * environment (a Hash)
#
# ==== User Exception Data
#   The following data is optional, User data is published if the 'send-user-data' configuration variable is set. 
# This data is based on the current_user
#
#      * user_id (String, current_user.user_id)
#      * user_login (String, current_user.user_login)
#      * user_email (String, current_user.user_email)
    
  module Api
  
    # parse an exception into an ExceptionData object
    def parse(exception)
      exception_data = ExceptionData.new
      exception_data.exception_backtrace = exception.backtrace
      exception_data.exception_message = exception.message
      exception_data.exception_class = exception.class.to_s
      exception_data
    end

    # used with Rails, takes an exception, controller, request and parameters
    # creates an ExceptionData object
    def handle(exception, controller, request, params, current_user = nil)
      Exceptional.log! "Handling #{exception.message}", 'info'
      begin
        e = parse(exception)
        # Additional data for Rails Exceptions
        e.framework = "rails"
        e.controller_name = controller.controller_name
        e.action_name = controller.action_name
        e.application_root = Exceptional.application_root
        e.occurred_at = Time.now.strftime("%Y%m%d %H:%M:%S %Z")
        e.environment = request.env.to_hash
        e.url = "#{request.protocol}#{request.host}#{request.request_uri}"
        e.environment = safe_environment(request)
        e.session = safe_session(request.session)
        e.parameters = sanitize_hash(params.to_hash)

        # Add info about current user if configured to do so        
        add_user_data(e, current_user) if(Exceptional.send_user_data? && !current_user.nil?)

        post(e)      
        Exceptional.log! "Exception #{exception} sent to #{Exceptional.remote_host}", 'debug'              
      rescue Exception => exception
        Exceptional.log! "Error preparing exception data."
        Exceptional.log! exception.message
        Exceptional.log! exception.backtrace.join("\n"), 'debug'
      end
    end

    # rescue any exceptions within the given block,
    # send it to exceptional,
    # then raise
    def rescue(&block)
      begin
        block.call
      rescue Exception => e
        self.catch(e)
        raise(e)
      end
    end

    def catch(exception)
      Exceptional.log! "Handling #{exception.message}", 'info'
      exception_data = parse(exception)
      exception_data.controller_name = File.basename($0)
      post(exception_data)
    end

    protected

    def safe_environment(request)
      safe_environment = request.env.dup.to_hash
      # From Rails 2.3 these objects that cause a circular reference error on .to_json need removed
      # TODO potentially remove this case, should be covered by sanitize_hash
      safe_environment.delete_if { |k,v| k =~ /rack/ || k =~ /action_controller/ || k == "_"}
      # needed to add a filter for the hash for "_", causing invalid xml.
      sanitize_hash(safe_environment)
    end

    def safe_session(session)
      result = {}
      session.instance_variables.each do |v|
        next if v =~ /cgi/ || v =~ /db/ || v =~ /env/
        var = v.sub("@","") # remove prepended @'s
        result[var] = session.instance_variable_get(v)
      end
      sanitize_hash(result)
    end

    private

    # post the given exception data to getexceptional.com
    def post(exception_data)
      hash = exception_data.to_hash
      if hash[:session]
        hash[:session].delete("initialization_options")
        hash[:session].delete("request")
      end

      Exceptional.post_exception(hash.to_json)
    end

    def sanitize_hash(hash)
      return {} if hash.nil?
      hash.reject { |key, val| !ensure_json_able(val) }
    end

    def ensure_json_able(value)
      begin
        value.to_json
        true && value.instance_values.all? { |e| ensure_json_able(e)}        
      rescue Exception => e
        false
      end
    end
    
    def add_user_data(exception_data, user)
      exception_data.user_id = user.id.to_s if user.respond_to? 'id'
      exception_data.user_login = user.login.to_s if user.respond_to? 'login'
      exception_data.user_email = user.email.to_s if user.respond_to? 'email'
    end
  end
end