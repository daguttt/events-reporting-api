class ReportsController < ApplicationController
  def create
    type = params[:type]
    case type
    when "attendance"
      AttandanceService.createReport
    when "tickets"
      TicketServices.createReport
    end
  end

  def get_history
  end

  def schedule
  end
end
