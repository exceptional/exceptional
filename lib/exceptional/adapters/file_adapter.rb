require 'exceptional/utils/file_utils'
require 'exceptional/adapters/base_adapter'

require 'ftools'

module Exceptional
  module Adapters

    class FileAdapterException < StandardError    #:nodoc:
    end

    class FileAdapter < BaseAdapter   #:nodoc:

      include Exceptional::Utils::FileUtils

      EXCEPTIONAL_FILE_PREFIX = "exceptional"

      #Override
      def bootstrap
        begin
          ensure_directory(Exceptional.work_dir, Exceptional.log)
        rescue Exception => e
          raise FileAdapterException.new(e.message)
        end
      end

      def publish_exception(json_data)
        begin
          file_name = "#{EXCEPTIONAL_FILE_PREFIX}-#{Time.now.strftime('%Y%m%d-%H%M%S')}.json"

          except_file = File.join(Exceptional.work_dir, file_name)
          Exceptional.log! "Creating Exception file #{except_file}"

          File.open(except_file, 'w') {|f|
            f.write(json_data)
          }

          # Return fact that file now exists
          FileTest.exists?(except_file)
        rescue Exception => e
          raise FileAdapterException.new(e.message)
        end
      end
    end
  end
end