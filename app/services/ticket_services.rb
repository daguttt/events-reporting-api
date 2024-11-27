require "net/http"
require "uri"
require "csv"

class TicketServices
  def self.create_report(ticket_params)

    # raw_data = get_ticket_summary
    # total_tickets = raw_data["data"].total_tickets
    # sold_tickets = raw_data["data"].sold_tickets

    total_tickets = 100
    sold_tickets = 70


    # EventsService.find_by_id(ticket_params[:event_id]) != nil
    if true
      new_ticket_report = TicketReport.create(capacity: total_tickets)

      current_date = Time.now

      format = Report.formats[ticket_params[:format]&.downcase]

      new_report = new_ticket_report.create_report(
        event_id: ticket_params[:event_id],
        format: format,
        sold_tickets: sold_tickets,
        date: current_date,
      )

      # log = new_ticket_report.report.report_logs.create(status: :created, user_id: ticket_params[:user_id])
      case ticket_params[:format]&.downcase
      when "json"
        {
        id: new_ticket_report.id,
        total_tickets: new_ticket_report.capacity,
        event_id: new_report.event_id,
        format: new_report.format,
        sold_tickets: new_report.sold_tickets,
        date: new_report.date,
        created_at: new_report.created_at
            }
      when "pdf"
      when "csv"
        {
        success: true,
        ticket_report: new_ticket_report,
        report: new_report,
        csv_data: generate_csv(new_ticket_report, new_report) # Generar CSV
      }
      end
    end
  end

  private
  def self.generate_csv(ticket_report, report)
    CSV.generate(headers: true) do |csv|
      csv << ["Ticket Report ID", "Total Tickets", "Event ID", "Format", "Sold Tickets", "Date", "Created At"]

      csv << [
        ticket_report.id,
        ticket_report.capacity,
        report.event_id,
        report.format,
        report.sold_tickets,
        report.date,
        report.created_at
      ]
    end
  end

  def get_ticket_summary
    uri = URI('asdas')
    response_tkts = Net::HTTP.get(uri)
    response_tkts_parsed = JSON.parse(response_tkts.body)
  end
end
