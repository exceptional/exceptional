require 'rubygems'

if ENV['RAILS_VER']
  gem 'rails', "=#{ENV['RAILS_VER']}"
else
  gem 'rails'
end

# TODO couple of different ways to test parts of exceptional with Rails (or a mock), reconcile them.
#require 'active_support'
# module Rails; end # Rails faker

require File.dirname(__FILE__) + '/../lib/exceptional'
