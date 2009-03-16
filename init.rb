require 'exceptional'


def to_stderr(s)
  STDERR.puts "** [Exceptional] " + s
end

config_file = File.join(RAILS_ROOT,"/config/exceptional.yml")

begin
  Exceptional::Config.load_config(config_file, RAILS_ENV, RAILS_ROOT)

  if Exceptional::Config.enabled?
    Exceptional.startup
  end

rescue Exception => e
  to_stderr e
  to_stderr "Plugin disabled."
end
