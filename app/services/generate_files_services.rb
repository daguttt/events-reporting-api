class GenerateFilesServices
  require "csv"
  require "prawn"
  require "prawn/table"

  def self.generate_pdf(type, report, event)
    Prawn::Document.new do |pdf|
      if type== "tickets"
        Rails.logger.info "generando pdf"
        pdf.text "Ticket Report", size: 20, style: :bold
        pdf.move_down 20

        data = [
          [ "Field", "Value" ],
          [ "Event ID", event["id"].to_s ],
          [ "Event Name", event["name"] ],
          [ "Total Tickets", report.reportable.capacity.to_s ],
          [ "Sold Tickets", report.sold_tickets.to_s ],
          [ "Date", report.date.to_s ],
          [ "Created At", Time.now.to_s ]
        ]

        pdf.table(data, header: true, row_colors: [ "dddddd", "ffffff" ], position: :center) do
          cells.padding = 12
          cells.borders = [ :bottom ]
          cells.border_width = 1
          row(0).font_style = :bold
        end
      elsif type=="attendance"
        pdf.text "Attendance Report", size: 24, style: :bold, align: :center
        pdf.move_down 20
        data = [
          [ "Attribute", "Value" ],
          [ "ID", report.reportable.id.to_s ],
          [ "Event ID", report.event_id.to_s ],
          [ "Event Name", event["name"] ],
          [ "Event Date", report.date.to_s ],
          [ "Sold Tickets", report.sold_tickets.to_s ],
          [ "True Attendance", report.reportable.true_attendees ],
          [ "False Attendance", report.reportable.false_attendees  ],
          [ "Percentage", report.reportable.percentage  ]
        ]

        pdf.table(data, header: true, row_colors: [ "dddddd", "ffffff" ], position: :center) do
          cells.padding = 12
          cells.borders = [ :bottom ]
          cells.border_width = 1
          row(0).font_style = :bold
        end
      end
    end.render
  end

  def self.generate_csv(type, report, event)
    CSV.generate(headers: true) do |csv|
      if type== "tickets"
        csv << [ "Ticket Report ID", "Total Tickets", "Event ID", "Format", "Sold Tickets", "Date", "Created At" ]

        csv << [
          report.reportable.id,
          report.reportable.capacity,
          report.event_id,
          report.format,
          report.sold_tickets,
          report.date,
          report.created_at
        ]
      elsif type=="attendance"
        csv << [ "NAME", "DATE", "SOLD TICKETS", "TRUE ATTENDANCE", "FALSE ATTENDANCE", "PERCENTAGE" ]
        csv << [ report.reportable.id, event["id"], event["name"], report.date, report.sold_tickets, report.reportable.true_attendees, report.reportable.false_attendees, report.reportable.percentage ]
      end
    end
  end
end
