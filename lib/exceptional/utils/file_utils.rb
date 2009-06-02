module Exceptional
  module Utils  #:nodoc:
    module FileUtils  #:nodoc:

      class FileUtilsException < StandardError    #:nodoc:
      end

      def ensure_directory(dir, log)
         if ! (FileTest.exists?(dir) && FileTest.directory?(dir))

            if !FileTest.exists?(File.dirname(dir)) #Parent dir has to exist
              raise FileUtilsException.new("Invalid Directory - #{File.expand_path(dir)}")
            else
              log.send("Creating Directory #{File.expand_path(dir)}")
              Dir.mkdir(dir)
            end
          end

          FileTest.exists?(dir) # Return that the directory exists        
      end      
    end
  end
end
