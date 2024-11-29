class ReportsController < ApplicationController
  # @summary Creates an attendance or ticket report
  # @tags Reports
  def create
    type = params[:type]

    case type
    when "attendance"
      data = AttendanceServices.create_report(report_params)
    when "tickets"
      data = TicketServices.create_report(report_params)
    else
      render json: { error: "Type '#{type}' not allowed" }, status: :unprocessable_entity
      return
    end
    format = params[:format]&.downcase&.to_sym
    case format
    when :pdf
      send_data(
        data[:pdf_data],  # El contenido del PDF generado
        filename: "#{type}_report_#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf",
        type: "application/pdf",
        disposition: "attachment"
      )
    when :csv
      send_data(
      data[:csv_data],
      filename: "#{type}_report_#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf",
      type: "text/csv",
      disposition: "attachment"
      )
    when :json
      render json: {
      success: true,
      message: "Report and #{type} Report created successfully",
      data: {
          report: data
        }
      }

    else
      render json: {
        success: false,
        message: "Unsupported format",
        data: {}
      }, status: :unprocessable_entity
    end
  end

  # @summary Get an event's reports history
  # @tags Reports
  def get_logs
    logs = RecordServices.get_logs
    render json: logs, status: :ok
  end

  # @summary Get reports history
  # @tags History
  def get_reports
    reports = RecordServices.get_reports
    render json: reports, status: :ok
  end

  # @summary Schedule the generation of a report
  # @tags Reports
  def schedule
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

  # @summary Get a report with id and generate the file report
  # @tags History
  def inspect_report
    report_id = params[:report_id]
    user_id = params[:user_id]
    report = Report.find_by(id: report_id)
    format = report.format&.downcase
    puts format
    result = RecordServices.inspect_report(report, user_id, format)
    if result[:error]
      render json: { error: result[:error] }, status: :not_found
    else
      if format == "pdf"
        send_data(
        result[:data],
        filename: "report_#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf",
        type: "application/pdf",
        disposition: "attachment"
      )
      elsif format == "csv"
        send_data(
        result[:data],
        filename: "report_#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf",
        type: "text/csv",
        disposition: "attachment"
        )
      elsif format == "json"

      else
        { message: "Format not supported" }
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

  private
  def report_params
    params.permit(:type, :user_id, :format, :event_id, report: [ :format ])
  end

  private
  def content_types
    {
    pdf: "application/pdf",
    csv: "text/csv",
    json: "application/json"
    }
  end
end
