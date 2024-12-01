require "net/http"
require "uri"
require "csv"
require "prawn"
require "prawn/table"

class TicketsService
  def self.create_report(ticket_params)
    # Validate event existance
    found_event = EventsService.find_by_id(ticket_params[:event_id])
    raise "Event not found" unless found_event

    tickets_summary = get_ticket_summary(ticket_params[:event_id])
    total_tickets = tickets_summary["total_tickets"]
    sold_tickets = tickets_summary["sold_tickets"]

    new_ticket_report = TicketReport.create(capacity: total_tickets)

    current_date = Time.now

    format = Report.formats[ticket_params[:format]&.downcase]

    new_report = new_ticket_report.create_report(
      event_id: ticket_params[:event_id],
      format: format,
      sold_tickets: sold_tickets,
      date: current_date,
    )

    new_ticket_report.report.report_logs.create(status: :created, user_id: ticket_params[:user_id])
    case ticket_params[:format]&.downcase
    when "json"
      {
      id: new_ticket_report.id,
      total_tickets: new_ticket_report.capacity,
      event_id: new_report.event_id,
      format: new_report.format,
      sold_tickets: new_report.sold_tickets,
      date: new_report.date,
      created_at: current_date
          }
    when "pdf"
      pdf_data = GenerateFilesServices.generate_pdf("tickets", new_report, found_event)

      {
        ticket_report: {
          id: new_ticket_report.id,
          total_tickets: new_ticket_report.capacity,
          event_id: new_report.event_id,
          format: new_report.format,
          sold_tickets: new_report.sold_tickets,
          date: new_report.date,
          created_at: new_report.created_at
        },
        pdf_data: pdf_data
      }
    when "csv"
      {
      success: true,
      ticket_report: new_ticket_report,
      report: new_report,
      csv_data: GenerateFilesServices.generate_csv("tickets", new_report, found_event) # Generar CSV
    }
    end
  end

  private
  def self.get_ticket_summary(event_id)
    uri = URI.parse("#{ENV.fetch("TICKET_URL")}/events/#{event_id}/tickets/summary")
    response_tkts = Net::HTTP.get_response(uri)
    JSON.parse(response_tkts.body)
  end
end
