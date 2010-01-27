# -*- encoding: utf-8 -*-
require File.expand_path('../lib/exceptional/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = %q{exceptional}
  gem.version = Exceptional::VERSION
  gem.authors = ["Contrast"]
  gem.summary = %q{ getexceptional.com is a hosted service for tracking errors in your Ruby/Rails/Rack apps }
  gem.description = %q{Exceptional is the Ruby gem for communicating with http://getexceptional.com (hosted error tracking service). Use it to find out about errors that happen in your live app. It captures lots of helpful information to help you fix the errors.}
  gem.email = %q{hello@contrast.ie}
  gem.files =  Dir['lib/**/*'] + Dir['spec/**/*'] + Dir['spec/**/*'] + Dir['rails/**/*'] + Dir['tasks/**/*'] + Dir['*.rb'] + ["exceptional.gemspec"]
  gem.homepage = %q{http://getexceptional.com/}
  gem.require_paths = ["lib"]
  gem.executables << 'exceptional'
  gem.rubyforge_project = %q{exceptional}
  gem.requirements << "json_pure, json-jruby or json gem required"
end
