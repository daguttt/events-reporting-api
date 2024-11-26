require "net/http"
require "uri"

class TicketServices
  def self.create_report(ticket_params)
    uri = URI('asdafsd')
    # response_tkts = Net::HTTP.get(uri)
    # total_tickets = response_tkts.total_tickets
    # sold_tickets = response_tkts.total_tickets

    total_tickets = 100
    sold_tickets = 70

    data = EventsService.find_by_id(ticket_params[:user_id])

    puts data.inspect

    # new_ticket_report = TicketReport.create(capacity: total_tickets)

    # current_date = Time.now

    # format = Report.formats[ticket_params[:format]]

    # newReport = new_ticket_report.create_report(
    #   event_id: ticket_params[:event_id],
    #   format: format,
    #   sold_tickets: sold_tickets,
    #   date: current_date,
    # )

    # log = new_ticket_report.report.report_logs.create(status: :created, user_id: ticket_params[:user_id])

    case ticket_params[:format]
    when "pdf"

    when "csv"

    when "json"

    end
  end




  private
  def self.pdf_report
  end
end
