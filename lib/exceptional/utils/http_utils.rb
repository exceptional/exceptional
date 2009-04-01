require 'zlib'
require 'cgi'
require 'net/http'

module Exceptional
  module Utils
    module HttpUtils

      class HttpUtilsException < StandardError; end

      ::PROTOCOL_VERSION = 3
      # TODO should retry if a http connection failed
      
      def http_call_remote(method, data)
        begin
          http = Net::HTTP.new(Exceptional.remote_host, Exceptional.remote_port)
          http.use_ssl = true if Exceptional.ssl_enabled?
          uri = "/#{method.to_s}?&api_key=#{Exceptional.api_key}&protocol_version=#{::PROTOCOL_VERSION}"
          headers = method.to_s == 'errors' ? { 'Content-Type' => 'application/x-gzip', 'Accept' => 'application/x-gzip' } : {}

          compressed_data = CGI::escape(Zlib::Deflate.deflate(data, Zlib::BEST_SPEED))
          response = http.start do |http|
            http.post(uri, compressed_data, headers)
          end

          if response.kind_of? Net::HTTPSuccess
            return response.body
          else
            raise HttpUtilsException.new("#{response.code}: #{response.message}")
          end

        rescue Exception => e
          Exceptional.log! "Error contacting Exceptional: #{e}", 'info'
          Exceptional.log! e.backtrace.join("\n"), 'debug'
          raise e
        end
      end
    end
  end
end
