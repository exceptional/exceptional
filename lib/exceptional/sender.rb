require 'zlib'
require 'cgi'
require 'net/http'
require 'net/https'
require 'digest/md5'

module Exceptional
  class Sender
    class << self
      def startup_announce(startup_data)
        url = "/api/announcements?api_key=#{::Exceptional::Config.api_key}&protocol_version=#{::Exceptional::PROTOCOL_VERSION}"
        compressed = Zlib::Deflate.deflate(startup_data.to_json, Zlib::BEST_SPEED)
        call_remote(url, compressed)
      end

      def error(exception_data)
        send(:"error_to_#{Exceptional::Config.send_to}", exception_data)
      end

      private

      def error_to_stdout(exception_data)
        Exceptional::Config.stdout_printer.call(exception_data)
      end

      def error_to_log(exception_data)
        Exceptional::Config.log_printer.call(exception_data)
      end

      def error_to_api(exception_data)
        uniqueness_hash = exception_data.uniqueness_hash
        hash_param = uniqueness_hash.nil? ? nil : "&hash=#{uniqueness_hash}"
        url = "/api/errors?api_key=#{::Exceptional::Config.api_key}&protocol_version=#{::Exceptional::PROTOCOL_VERSION}#{hash_param}"
        compressed = Zlib::Deflate.deflate(exception_data.to_json, Zlib::BEST_SPEED)
        call_remote(url, compressed)
      end

      def call_remote(url, data)
        config = Exceptional::Config
        optional_proxy = Net::HTTP::Proxy(config.http_proxy_host,
                                          config.http_proxy_port,
                                          config.http_proxy_username,
                                          config.http_proxy_password)
        client = optional_proxy.new(config.remote_host, config.remote_port)
        client.open_timeout = config.http_open_timeout
        client.read_timeout = config.http_read_timeout
        client.use_ssl = config.ssl?
        client.verify_mode = OpenSSL::SSL::VERIFY_NONE if config.ssl?
        begin
          response = client.post(url, data)
          case response
            when Net::HTTPSuccess
              Exceptional.logger.info("#{url} - #{response.message}")
              return true
            else
              Exceptional.logger.error("#{url} - #{response.code} - #{response.message}")
          end
        rescue Exception => e
          Exceptional.logger.error('Problem notifying Exceptional about the error')
          Exceptional.logger.error(e)
        end
        nil
      end
    end
  end
end