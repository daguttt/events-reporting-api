class ReportsController < ApplicationController
  # @summary Creates an attendance or ticket report
  # @tags Reports
  def create
    type = params[:type]
    case type
    when "attendance"
      data = AttendanceService.create_report(report_params)
      case params[:format]&.downcase
      when "pdf"
        send_data(
            data,
            filename: "attendance_report_#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf",
            type: "application/pdf",
            disposition: "attachment"
          )

      when "csv"
        send_data(
            data,
            filename: "attendance_report_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv",
            type: "text/csv",
            disposition: "attachment"
          )
      when "json"
        render json: {
        success: true,
        message: "Report and Attendance Report created successfully",
        data: {
            attendance_report: data
          }
        }
      end
    when "tickets"
      data = TicketsService.create_report(report_params)
      case params[:format]&.downcase
      when "pdf"
        send_data(
            data[:pdf_data], # Aquí se usa el contenido generado por el servicio
            filename: "ticket_report_#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf",
            type: "application/pdf",
            disposition: "attachment"
          )

      when "csv"
        send_data(
            data[:csv_data], # Aquí se usa el contenido generado por el servicio
            filename: "ticket_report_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv",
            type: "text/csv",
            disposition: "attachment"
          )
      when "json"
        render json: {
        success: true,
        message: "Report and Ticket Report created successfully",
        data: {
            ticket_report: data
          }
        }
      end
    else
      render json: {
        error: "invalid report type"
      }, status: :bad_request
    end
  end

  # @summary Get an event's reports history
  # @tags Reports
  def get_history
  end

  # @summary Schedule the generation of a report
  # @tags Reports
  # @request_body The parameters for scheduling a report [!Hash{ frequency: String, user_id: Integer, format: String, report: Hash}]
  # @request_body_example A complete request to schedule a report [Hash] { frequency: "daily", user_id: 2, format: "pdf", report: {}}

  # @response Event not found (404) [Hash{success: Boolean, message: String}]
  # @response_example event not found (404) [{ success: false, message: "Event not found" }]

  # @response Invalid frequency (422) [Hash{success: Boolean, message: String}]
  # @response_example invalid frequency (422) [{ success: false, message: "Invalid frequency" }]

  # @response Report scheduled successfully (200) [Hash{success: Boolean, message: String}]
  # @response_example scheduled successfully (200) [{ success: true, message: "Report scheduled successfully" }]

  def schedule
    event_id = schedule_report_params[:event_id]
    frequency = schedule_report_params[:frequency]
    format = schedule_report_params[:format]
    # Check if the event exists
    event = EventsService.find_by_id(event_id)
    unless event
      render json: { error: "Event not found" }, status: :not_found
      return
    end

    # Check if the frequency is valid
    unless %w[daily weekly monthly].include?(frequency)
      render json: { error: "Invalid frequency" }, status: :unprocessable_entity
      return
    end

    ReportSchedulerJob.perform_async(event_id, frequency, format)
    render json: { success: true, message: "Report scheduled successfully" }, status: :ok
  end

  private
  def report_params
    params.permit(:type, :user_id, :format, :event_id, report: [ :format ])
  end

  def schedule_report_params
    params.require([ :event_id, :frequency, :user_id, :format ])
    params.permit(:event_id, :frequency, :user_id, :format, report: {})
  end
end
