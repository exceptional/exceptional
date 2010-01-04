require 'spec/rake/spectask'

task :default => [:spec]

Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--color']
end

desc 'Run specs using ginger to test against all supported rails versions'
task :ginger do
  ARGV.clear
  ARGV << 'spec'
  load File.join(*%w[spec bin ginger])
end
