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

  def get_history
  end

  def schedule
  end

  def report_params
    params.require(:ticket_report).permit(:type, :user_id, :format)
  end
end
