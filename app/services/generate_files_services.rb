class GenerateFilesServices
  require "csv"
  require "prawn"
  require "prawn/table"

  def self.generate_pdf(new_ticket_report, new_report)
    Prawn::Document.new do |pdf|
      pdf.text "Ticket Report", size: 20, style: :bold
      pdf.move_down 20

      # Generar la tabla
      data = [
        [ "Field", "Value" ],
        [ "Event ID", "1" ],
        [ "Total Tickets", "100" ],
        [ "Sold Tickets", "15" ],
        [ "Date", "2024-12-12" ],
        [ "Created At", Time.now.to_s ]
      ]

      pdf.table(data, header: true, row_colors: [ "dddddd", "ffffff" ], position: :center) do
        cells.padding = 12
        cells.borders = [ :bottom ]
        cells.border_width = 1
        row(0).font_style = :bold
      end
    end.render
  end

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
end
