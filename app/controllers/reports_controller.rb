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
    when "tickets"
      data = TicketsService.create_report(report_params)
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

  # @summary Get a report with id and generate the file report
  # @tags History
  def inspect_report
    report_id = params[:report_id]
    user_id = params[:user_id]
    report = Report.find_by(id: report_id)
    format = report.format&.downcase
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

  private
  def report_params
    params.permit(:type, :user_id, :format, :event_id, report: [ :format ])
  end

  def schedule_report_params
    params.require([ :event_id, :frequency, :user_id, :format ])
    params.permit(:event_id, :frequency, :user_id, :format, report: {})
  end
end
