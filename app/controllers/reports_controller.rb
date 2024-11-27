class ReportsController < ApplicationController
  # @summary Creates an attendance or ticket report
  # @tags Reports
  def create
  end

  # @summary Get an event's reports history
  # @tags Reports
  def get_history
  end

  def delete
    event_id = 1
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


  # @summary Schedule the generation of a report
  # @tags Reports
  def schedule
    event_id = 1
    frequency = "weekly"

    # Check if the event exists
    # event = Event.find_by(id: event_id)
    # unless event
    #   render json: { error: "Event not found" }, status: :not_found
    #   return
    # end

    # # Check if the frequency is valid
    # unless %w[daily weekly monthly].include?(frequency)
    #   render json: { error: "Invalid frequency" }, status: :unprocessable_entity
    #   return
    # end

    case frequency

    when "daily"
      # Schedule the job to run again every day at the same time (i.e., 24 hours later).
      ReportSchedulerJob.perform_async(event_id, "daily")
    when "weekly"
      # Schedule the job to run again every week at the same day and time.
      ReportSchedulerJob.perform_async(event_id, "weekly")
    when "monthly"
      # Schedule the job to run again every month at the same day and time.
      ReportSchedulerJob.perform_async(event_id, "monthly")
    else
      # Handle the case where an unsupported frequency is passed
      logger.error("Unsupported frequency: #{frequency} for event ID #{event_id}. Job will not be rescheduled.")
    end
  end
end
