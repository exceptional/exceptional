require 'ftools'
require File.dirname(__FILE__) + '/file_utils'

module Exceptional
  module Utils

    class FileSweeperException < StandardError; end

    class FileSweeper

      include Exceptional::Utils::FileUtils

      # This shouldnt need to be passed, should be figured out from the current environment somehow
      def initialize(config_file, work_dir, application_root, log)
        Exceptional.setup_config("common", config_file)

        ensure_work_directory(log)

        @adapter = Exceptional::Adapters::HttpAdapter.new
        @log = log
      end

      def sweep
        @log.send "info", "FileAdapter Sweep Starting #{Exceptional.work_dir}"
        begin
          Dir.glob("#{Exceptional.work_dir}/*.json") { |file|
            @log.send "info", "File Adapter Sweep - Found #{file}"
            json_data = read_data(file)
            @adapter.publish_exception(json_data.to_json)
            File.delete(file)
          }

        rescue Exception => e
          @log.send "error", "#{e.message}"
          raise FileSweeperException.new e.message
        ensure
          @log.send "info", "FileAdapter Sweep Finished"
        end
      end

      def read_data(filename)
        open(filename) do |f|
          json = f.read
          return JSON.parse(json.sub(/^[^{]+/, ''))
        end
      rescue => e
        raise FileSweeperException.new e.message
      end
    end
  end
end