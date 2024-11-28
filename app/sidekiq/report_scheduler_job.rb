class ReportSchedulerJob
  include Sidekiq::Job

  def perform(event_id, frequency)
    # TicketsService.createReport  --create the logic
    logger.info("report scheduled")

    # Determine the interval in seconds based on the frequency
    interval_in_seconds = case frequency
    when "daily" then 24 * 60 * 60  # 1 day
    when "weekly" then 7 * 24 * 60 * 60  # 1 week
    when "monthly" then 4 * 7 * 24 * 60 * 60  # 1 month
    else 0  # Default to no reschedule if frequency is not recognized
    end

    # Schedule the next job if interval_in_seconds is greater than 0
    if interval_in_seconds > 0
      find_and_cancel_job(event_id)
      schedule_next_job(interval_in_seconds, event_id, frequency)
    else
      logger.info("No rescheduling necessary.")
    end
  end

  private

  # Method to find and cancel an existing scheduled job
  def find_and_cancel_job(event_id)
    # Loop through all jobs in the Scheduled Set
    Sidekiq::ScheduledSet.new.each do |job|
      # Check if the job's arguments match the ones you're looking for
      if job.args[0] == event_id
        # Found a matching job, so you can delete it
        job.delete
        logger.info("Job with JID #{job.jid} has been deleted. Event ID: #{event_id}")
        return job.jid  # Optionally return the JID for reference
      end
    end
  end

  # Helper method to reschedule the job at a fixed interval
  def schedule_next_job(interval_in_seconds, event_id, frequency)
    # Calculate the next run time by adding the interval (in seconds) to the current time
    next_run_time = Time.now + interval_in_seconds

    # Schedule the next job at the exact time (this keeps it consistent)
    self.class.perform_at(next_run_time, event_id, frequency)

    # Output the next scheduled time for logging or debugging
    logger.info("Next #{frequency} job scheduled at: #{next_run_time}")
  end
end
