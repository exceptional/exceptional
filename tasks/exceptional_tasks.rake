namespace :exceptional do
  desc 'Send a test exception to Exceptional.'
  task :test => :environment do
    unless Exceptional::Config.api_key.blank?
      puts "Sending test exception to Exceptional."
      require "exceptional/integration/tester"
      Exceptional::Integration.test
      puts "Done."
    end
  end
end