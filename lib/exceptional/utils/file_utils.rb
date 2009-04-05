

module Exceptional
  module Utils
    module FileUtils

      class FileUtilsException < StandardError; end

      def ensure_work_directory (log)
        if ! (FileTest.exists?(Exceptional.work_dir) && FileTest.directory?(Exceptional.work_dir))

          if !FileTest.exists?(File.dirname(Exceptional.work_dir)) #Parent dir has to exist
            raise FileUtilsException.new "Invalid Directory - #{File.expand_path(Exceptional.work_dir)}"
          else
            log.send('info', "Creating Directory #{File.expand_path(Exceptional.work_dir)}")
            Dir.mkdir(Exceptional.work_dir)
          end
        end
      end
    end
  end
end
