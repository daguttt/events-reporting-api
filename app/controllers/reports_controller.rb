class ReportsController < ApplicationController
  def create
    type = params[:type]
    case type
    when "attendance"
      AttandanceService.create_report
    when "tickets"
      TicketServices.create_report(params)
    end
  end

  def get_logs
    logs = RecordServices.get_logs
    render json: logs, status: :ok
  end

  def get_reports
    reports = RecordServices.get_reports
    render json: reports, status: :ok
  end

  def schedule
  end

  def inspect_report
    report_id = params[:report_id]
    puts report_id
    user_id = params[:user_id] # Asegúrate de recibir el parámetro
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
