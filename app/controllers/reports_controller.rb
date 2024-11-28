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
      data = TicketServices.create_report(report_params)
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
    end
  end

  # @summary Get an event's reports history
  # @tags Reports
  def get_history
  end

  # @summary Schedule the generation of a report
  # @tags Reports
  def schedule
  end

  private
  def report_params
    params.permit(:type, :user_id, :format, :event_id, report: [ :format ])
  end
end
