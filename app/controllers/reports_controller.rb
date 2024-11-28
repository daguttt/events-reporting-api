class ReportsController < ApplicationController
  # @summary Creates an attendance or ticket report
  # @tags Reports
  def create
    type = params[:type]
    case type
    when "attendance"
      AttandanceService.create_report
    when "tickets"
      TicketServices.create_report(params)
    end
    type = params[:type]
    case type
    when "attendance"
      AttandanceService.create_report()
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
  def get_logs
    logs = RecordServices.get_logs
    render json: logs, status: :ok
  end

  def get_reports
    reports = RecordServices.get_reports
    render json: reports, status: :ok
  end

  # @summary Schedule the generation of a report
  # @tags Reports
  def schedule
  end

  def inspect_report
    report_id = params[:report_id]
    puts report_id
    user_id = params[:user_id]
    result = RecordServices.inspect_report(report_id, user_id)
    if result[:error]
      render json: { error: result[:error] }, status: :not_found
    else
      render json: result, status: :ok
    end
  end

  def report_params
    params.require(:ticket_report).permit(:type, :user_id, :format)
  end
end
