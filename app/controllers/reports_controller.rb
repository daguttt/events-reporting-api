class ReportsController < ApplicationController
  # @summary Creates an attendance or ticket report
  # @tags Reports
  def create
    type = params[:type]
    case type
    when "attendance"
      AttendanceService.create_report(params)
    when "tickets"
      TicketServices.create_report
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
  def attendance_report_params
  end
end
