class Delayed::Worker
  def handle_failed_job_with_exceptional(job, e)
    Exceptional.handle(e, "Delayed::Worker \"#{self.name}\" died")
    handle_failed_job_without_exceptional(job, e)
    Exceptional.context.clear!
  end
  alias_method_chain :handle_failed_job, :exceptional
  Exceptional.logger.info "DJ integration enabled"
end