if Delayed::Worker.method_defined? :handle_failed_job
  class Delayed::Worker
    def handle_failed_job_with_exceptional(job, e)
      Exceptional.handle(e, "Delayed::Job #{job.name}")
      handle_failed_job_without_exceptional(job, e)
      Exceptional.context.clear!
    end
    alias_method_chain :handle_failed_job, :exceptional
    Exceptional.logger.info "DJ integration enabled"
  end
else
  message = "\n\n\nThe Exceptional gem does not support Delayed Job 1.8.4 or earlier.\n\n\n"
  STDERR.puts(message)
  Exceptional.logger.error(message)
end