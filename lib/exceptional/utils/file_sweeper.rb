require 'ftools'

module Exceptional
  module Utils

    class FileSweeperException < StandardError; end

    class FileSweeper

      DEFAULT_ENVIRONMENT = "production"

      def initialize(config_file, work_dir, application_root, log)
        Exceptional.setup_config(DEFAULT_ENVIRONMENT, config_file)
        Exceptional.work_dir = work_dir

        if ! (FileTest.directory?(Exceptional.work_dir) && FileTest.exists?(Exceptional.work_dir))
          raise FileSweeperException.new "Invalid Sweep Directory - #{Exceptional.work_dir}"
        end

        @adapter = Exceptional::Adapters::HttpAdapter.new
        @log = log
      end

      def sweep
        @log.send "info", "FileAdapter Sweep Starting"
        begin
          Dir.glob("#{Exceptional.work_dir}/*.json") {|file|
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
