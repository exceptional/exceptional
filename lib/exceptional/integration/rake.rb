module Exceptional::Rake
  # Integrates Exceptional with Rake
  # 
  # Usage:
  #
  # Simply load it inside of your Rakefile.
  #
  # require "exceptional"
  # require "exceptional/integration/rake"
  # 
  # task :exceptional do
  #   ...
  #   # exception happens here
  #   raise SomeUnexpectedException
  #   ...
  # end
  #
  #
  # Remember to load your Exceptional configuration if
  # you're using Exceptional outside Rails
  #
  # Exceptional::Config.load("/path/to/config.yml")
  #
  def self.included(base)
    base.send(:alias_method,
              :standard_exception_handling,
              :standard_exception_handling_with_exceptional)
  end

  def standard_exception_handling_with_exceptional
      begin
        yield
      rescue SystemExit => ex
        # Exit silently with current status
        raise
      rescue OptionParser::InvalidOption => ex
        $stderr.puts ex.message
        exit(false)
      rescue Exception => ex
        # Exit with error message
        Exceptional::Catcher.handle(ex)
        display_error_message(ex)
        Exceptional.clear!
        exit(false)
      end
  end
end

Rake::Application.send(:include,Exceptional::Rake)

Exceptional.logger.info "Rake integration enabled"
