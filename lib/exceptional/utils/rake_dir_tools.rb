module Exceptional
  module Utils  #:nodoc:
    module RakeDirTools  #:nodoc:

      EXCEPTIONAL_CONFIG_FILE = "exceptional.yml" if !defined? EXCEPTIONAL_CONFIG_FILE
      RELATIVE_RAILS_ROOT = "../../../../../../" if !defined? RELATIVE_RAILS_ROOT
      RELATIVE_RAILS_CONFIG_PATH = RELATIVE_RAILS_ROOT + "config" if !defined? RELATIVE_RAILS_CONFIG_PATH
      RELATIVE_WORK_DIR_PATH = RELATIVE_RAILS_ROOT + "tmp/exceptional" if !defined? RELATIVE_WORK_DIR_PATH

      def RakeDirTools.get_config_dir
        if !ENV['config_dir'].nil?
          return ENV['config_dir']
        else
          return File.join(File.dirname(__FILE__), RELATIVE_RAILS_CONFIG_PATH)
        end
      end

      def RakeDirTools.get_config_file
        # Exceptional Config File
        if !ENV['config_file'].nil?
          config_file = ENV['config_file']
        else
          rails_config_dir = get_config_dir

          if !FileTest.directory?(rails_config_dir)
            STDERR.puts "Invalid Config Directory #{File.expand_path(rails_config_dir)}"
            raise IOError.new "Exceptional Config File not found #{File.expand_path(config_file)}"
          end

          config_file = File.join(rails_config_dir, EXCEPTIONAL_CONFIG_FILE)
        end

        if !FileTest.exists?(config_file)
          STDERR.puts "Exceptional Config File not found #{File.expand_path(config_file)}"
          raise IOError.new "Exceptional Config File not found #{File.expand_path(config_file)}"
        end

        return config_file
      end

      def RakeDirTools.get_rails_root
        # The application root
        if !ENV['rails_root'].nil?
          rails_root = ENV['rails_root']
        else
          rails_root = File.join(File.dirname(__FILE__), RELATIVE_RAILS_ROOT)
        end
      end
      
      def RakeDirTools.get_work_dir
        if !ENV['work_dir'].nil?
          return ENV['work_dir']
        else
          return File.join(File.dirname(__FILE__), RELATIVE_WORK_DIR_PATH)
        end
      end
      
    end
  end
end