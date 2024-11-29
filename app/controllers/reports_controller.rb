class ReportsController < ApplicationController
  # @summary Create a report
  # @tags reports
  # @request_body Create a report. Needs to include`user_id | format | type`. [!Report]
  # @request_body_example basic user [Hash] {"user_id": 1,"format": "pdf","type": "attendance//ticket" }
  # @response event_id not found (404) [Hash{succes: Boolean, message: String}]
  # @response_example Placeholder (404) [{"success": false, "message": "Event not found"}]

  # @response Return different types of responses depending on the format you choose. If you choose pdf or csv, the response creates a file; if json is chosen, the full response (200) [Hash{success: Boolean, message: String, data: Hash{id: Integer, total_tickets: Integer, event_id: Integer, format: String, sold_tickets: Integer, date: DateTime, created_at: DateTime }}]
  # @response_example Placeholder (200) [{"success": true, message: "Report and Attendance Report created successfully", data: {id: 21, total_tickets: 100, event_id: 1, format: "json", sold_tickets: 70, date: "2024-11-28T18:28:27.887Z", created_at: "2024-11-28T18:28:27.903Z" }}]

  # @response Invalid report type (400) [Hash{error: String}]
  # @response_example Placeholder (400) [{ error: "invalid report type" }]
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
