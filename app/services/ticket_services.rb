require "net/http"
require "uri"
require "csv"
require "prawn"
require "prawn/table"

class TicketServices
  def self.create_report(ticket_params)
    # raw_data = get_ticket_summary
    # total_tickets = raw_data["data"].total_tickets
    # sold_tickets = raw_data["data"].sold_tickets

    total_tickets = 100
    sold_tickets = 70

    if EventsService.find_by_id(ticket_params[:event_id]) != nil
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
        pdf_data = generate_pdf(new_ticket_report, new_report)

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
        csv_data: generate_csv(new_ticket_report, new_report) # Generar CSV
      }
      end
    end
  end

  private
  def self.generate_csv(ticket_report, report)
    CSV.generate(headers: true) do |csv|
      csv << [ "Ticket Report ID", "Total Tickets", "Event ID", "Format", "Sold Tickets", "Date", "Created At" ]

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

  def self.generate_pdf(new_ticket_report, new_report)
    Prawn::Document.new do |pdf|
      pdf.text "Ticket Report", size: 20, style: :bold
      pdf.move_down 20

      # Generar la tabla
      data = [
        [ "Field", "Value" ],
        [ "Event ID", new_report.event_id.to_s ],
        [ "Total Tickets", new_ticket_report.capacity.to_s ],
        [ "Sold Tickets", new_report.sold_tickets.to_s ],
        [ "Date", new_report.date.to_s ],
        [ "Created At", new_report.created_at.to_s ]
      ]

      pdf.table(data, header: true, row_colors: [ "dddddd", "ffffff" ], position: :center) do
        cells.padding = 12
        cells.borders = [ :bottom ]
        cells.border_width = 1
        row(0).font_style = :bold
      end
    end.render
  end

  def get_ticket_summary
    uri = URI("asdas")
    response_tkts = Net::HTTP.get(uri)
    JSON.parse(response_tkts.body)
  end
end
