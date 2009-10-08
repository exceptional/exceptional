require 'zlib'
require 'cgi'
require 'net/http'

module Exceptional
  class Remote
    class << self
      def announce(json_data)
        # post to /announcements
      end

      def error(json_data)
        url = "/errors?api_key=#{Config.api_key}&protocol_version=#{::Exceptional::PROTOCOL_VERSION}"
        compressed = Zlib::Deflate.deflate(json_data,Zlib::BEST_SPEED)
        call_remote(url, compressed)
      end

      def call_remote(url, data)
        client = Net::HTTP.new(Exceptional::Config.remote_host, Exceptional::Config.remote_port)
        client.use_ssl = true if Exceptional::Config.ssl_enabled?
        client.post(url, data)
      end
    end
  end
end