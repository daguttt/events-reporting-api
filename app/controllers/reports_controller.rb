class ReportsController < ApplicationController
  def create
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

  def get_history
  end

  def schedule
  end

  private
  def report_params
    params.permit(:type, :user_id, :format, :event_id, report: [ :format ])
  end
end
