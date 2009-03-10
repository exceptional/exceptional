require 'rubygems'
if ENV['RAILS_VER']
  gem 'rails', "=#{ENV['RAILS_VER']}"
else
  gem 'rails'
end
require File.dirname(__FILE__) + '/../lib/exceptional'
