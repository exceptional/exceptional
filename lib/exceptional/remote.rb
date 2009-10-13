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
        url = "/api/errors?api_key=#{::Exceptional::Config.api_key}&protocol_version=#{::Exceptional::PROTOCOL_VERSION}"
        compressed = Zlib::Deflate.deflate(json_data,Zlib::BEST_SPEED)
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
        client.use_ssl = true if config.ssl_enabled?
        client.post(url, data)
      end
    end
  end
end