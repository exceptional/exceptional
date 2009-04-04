require 'ftools'

module Exceptional
  module Adapters

    class FileAdapterException < StandardError; end

    class FileAdapter

      EXCEPTIONAL_FILE_PREFIX = "exceptional"

      def publish_exception(json_data)
        begin


          file_name = "#{EXCEPTIONAL_FILE_PREFIX}-#{Time.now.strftime('%Y%m%d-%H%M%S')}.json"

          if ! (FileTest.directory?(Exceptional.work_dir) && FileTest.exists?(Exceptional.work_dir))
            if !FileTest.exists?(File.dirname(Exceptional.work_dir))
              raise FileAdapterException.new "Invalid Sweep Directory - #{Exceptional.work_dir}"
            else
              Exceptional.log! "Creating Directory #{Exceptional.work_dir}"
              Dir.mkdir(Exceptional.work_dir)
            end
          end

          except_file = File.join(Exceptional.work_dir, file_name)

          Exceptional.log! "Creating Exception file #{except_file}"

          File.open(except_file, 'w') {|f|
            f.write(json_data)
          }

          # Return fact that file now exists
          FileTest.exists?(except_file)

        rescue Exception => e
          raise FileAdapterException.new e.message
        end
      end

    end
  end
end
