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
  def display_error_message(ex)
    Exceptional.handle(ex, reconstruct_command_line)
    super(ex)
    Exceptional.clear!
  end 

  def reconstruct_command_line
    "rake #{ARGV.join( ' ' )}" 
  end 

end
Rake.application.instance_eval do
  class << self
    include Exceptional::RakeHandler
  end 
end
