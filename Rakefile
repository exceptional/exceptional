require 'appraisal'
require 'rubygems'
require 'bundler/setup'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/exceptional/**/*_spec.rb"
  t.rspec_opts = ['--color']
end

RSpec::Core::RakeTask.new(:test_integrations) do |t|
  t.pattern = "spec/integrations/*_spec.rb"
  t.rspec_opts = ['--color']
end

task :default => [:spec, :appraise]

task :appraise do
  exec 'rake appraisal test_integrations'
end
