class GenerateFilesServices
  require "csv"
  require "prawn"
  require "prawn/table"

  def self.generate_pdf(type, report)
    Prawn::Document.new do |pdf|
      if type== "tickets"
        pdf.text "Ticket Report", size: 20, style: :bold
        pdf.move_down 20

        data = [
          [ "Field", "Value" ],
          [ "Event ID", report.event_id.to_s ],
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
        puts report
        puts report.reportable
        table_data = [
          [ "Attribute", "Value" ],
          [ "ID", attendance_report.id ],
          [ "Event ID", get_event["id"] ],
          [ "Event Name", get_event["name"] ],
          [ "Event Date", get_event["date"] ],
          [ "Sold Tickets", sold_tickets ],
          [ "True Attendance", summary["true_attendees"] ],
          [ "False Attendance", summary["false_attendees"] ],
          [ "Percentage", percentage.to_s + "%" ]
        ]

        pdf.table(table_data, header: true, row_colors: [ "dddddd", "ffffff" ], position: :center) do
          cells.padding = 12
          cells.borders = [ :bottom ]
          cells.border_width = 1
          row(0).font_style = :bold
        end
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
