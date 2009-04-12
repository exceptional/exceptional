require 'ftools'
require File.dirname(__FILE__) + '/file_utils'

module Exceptional
  module Utils  #:nodoc:

    class FileSweeperException < StandardError    #:nodoc:
    end

    class FileSweeper  #:nodoc:

      include Exceptional::Utils::FileUtils

      # This shouldnt need to be passed, should be figured out from the current environment somehow
      def initialize(config_file, work_dir, application_root, log)
        Exceptional.setup_config("common", config_file)
        ensure_work_directory(log)
        @adapter = Exceptional::Adapters::HttpAdapter.new
        @log = log
      end

      def sweep
        @log.send "info", "FileAdapter Sweep Starting #{Exceptional.work_dir?}"

        Dir.glob("#{Exceptional.work_dir?}/*.json").each do |file|
          begin
            @log.send "info", "File Adapter Sweep - Found #{file}"
            json_data = read_data(file)
            @adapter.publish_exception(json_data.to_json)
            File.delete(file)
          rescue Exception => e
            @log.send "error", "#{e.message}"
            File.rename(file, "#{file} + .error")
            raise FileSweeperException.new e.message
          end
        end

        @log.send "info", "FileAdapter Sweep Finished"
      end

      private
      
      def adapter
        return @adapter
      end

      def read_data(filename)
        File.open(filename) do |f|
          json = f.read
          return JSON.parse(json.sub(/^[^{]+/, ''))
        end
      end
    end
  end
end