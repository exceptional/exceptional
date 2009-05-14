Gem::Specification.new do |s|
  s.name     = "exceptional"
  s.version  = "0.0.6"
  s.date     = "2008-11-4"
  s.summary  = "Exceptional is the core Ruby library for communicating with http://getexceptional.com (hosted error tracking service)"
  s.email    = "david@getexceptional.com"
  s.homepage = "http://github.com/contrast/exceptional"
  s.description = "Exceptional is the core Ruby library for communicating with http://getexceptional.com (hosted error tracking service)"
  s.has_rdoc = true
  s.authors  = ["David Rice", "Paul Campbell"]
  s.files    = ["History.txt", 
		"Manifest", 
		"README", 
		"Rakefile", 
		"exceptional.gemspec",
		"exceptional.yml",
		"init.rb", 
		"install.rb",
		"lib/exceptional/api.rb",
		"lib/exceptional/bootstrap.rb",
		"lib/exceptional/config.rb",
    "lib/exceptional/exception_data.rb",
    "lib/exceptional/integration/rails.rb",
    "lib/exceptional/log.rb",
    "lib/exceptional/remote.rb",
    "lib/exceptional/version.rb",
    "lib/exceptional.rb"]
  s.test_files = [
      "spec/api_spec.rb",
      "spec/bootstrap_spec.rb",
      "spec/config_spec.rb",
      "spec/exception_data_spec.rb",
      "spec/exceptional_rescue_from_spec.rb",
      "spec/exceptional_spec.rb",
      "spec/log_spec.rb",
      "spec/remote_spec.rb",
      "spec/spec_helper.rb"]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["History.txt", "Manifest", "README"]
  s.add_dependency("json", ["> 0.0.0"])
end
