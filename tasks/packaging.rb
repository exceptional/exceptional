require 'rake/rdoctask'

task :packagegem do
  begin
    require 'echoe'

    Echoe.new('exceptional', '0.0.1') do |p|
      p.rubyforge_name = 'exceptional'
      p.summary      = "Exceptional is the core Ruby library for communicating with http://getexceptional.com (hosted error tracking service)"
      p.description  = "Exceptional is the core Ruby library for communicating with http://getexceptional.com (hosted error tracking service)"
      p.url          = "http://getexceptional.com/"
      p.author       = ['David Rice']
      p.email        = "david@contrast.ie"
      p.dependencies = ["json"]
    end

  rescue LoadError => e
    puts "You are missing a dependency required for meta-operations on this gem."
    puts "#{e.to_s.capitalize}."
  end
end


desc 'Generate documentation'
Rake::RDocTask.new(:docs) do |rdoc|
  rdoc.rdoc_dir = 'docs/rdoc'
  rdoc.title    = "Exceptional - " + Exceptional::VERSION.to_s
  rdoc.options << '--line-numbers' << '--inline-source' 
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/exceptional/config.rb')
  rdoc.rdoc_files.include('lib/exceptional/api.rb')
  rdoc.rdoc_files.include('lib/exceptional/adapter_manager.rb')  
end
