begin
  class Delayed::Job
    def log_exception_with_exceptional(e)
      Exceptional.handle(e, "Delayed::Job #{self.name}")
      log_exception_without_exceptional(e)
      Exceptional.context.clear!
    end
    alias_method_chain :log_exception, :exceptional
  end
  puts "Exceptional Delayed::Job integration"
rescue
end