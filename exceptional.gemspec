# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = %q{exceptional}
  s.version = "2.0.7"
  s.authors = ["Contrast"]
  s.summary = %q{ getexceptional.com is a hosted service for tracking errors in your Ruby/Rails/Rack apps }
  s.description = %q{Exceptional is the Ruby gem for communicating with http://getexceptional.com (hosted error tracking service). Use it to find out about errors that happen in your live app. It captures lots of helpful information to help you fix the errors.}
  s.email = %q{hello@contrast.ie}
  s.files =  Dir['lib/**/*'] + Dir['spec/**/*'] + Dir['spec/**/*'] + Dir['rails/**/*'] + Dir['tasks/**/*'] + Dir['*.rb'] + ["exceptional.gemspec"]
  s.homepage = %q{http://getexceptional.com/}
  s.require_paths = ["lib"]
  s.executables << 'exceptional'
  s.rubyforge_project = %q{exceptional}
  s.requirements << "json_pure, json-jruby or json gem required"
end
