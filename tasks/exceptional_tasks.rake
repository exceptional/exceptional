namespace :exceptional do
  desc 'Send a test exception to Exceptional.'
  task :test => :environment do
    class ExceptionalTestException <StandardError; end
    data = Exceptional::ExceptionData.new(ExceptionalTestException.new)
    unless Exceptional::Config.api_key.blank?
      puts "Sending test exception to Exceptional"
      Exceptional::Remote.error(data.to_json)
      puts "Done."
    end
  end
end