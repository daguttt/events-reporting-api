require "net/http"
require "csv"
class AttendanceService
  def self.create_report(params)
    event_id = params[:event_id]
    format = params[:format]
    user_id = params[:user_id]
    summary = get_attendance_summary(event_id: event_id)
    sold_tickets = summary["true_attendees"] + summary["false_attendees"]
    percentage = summary["true_attendees"] * 100 / sold_tickets
    if EventsService.find_by_id(event_id) != nil
      attendance_report = AttendanceReport.create(percentage: percentage)
      attendance_report.create_report(
        date: Time.now,
        event_id: event_id,
        format: format,
        sold_tickets: sold_tickets
        )

        attendance_report.report.report_logs.create(status: :created, user_id: user_id)
        get_event = EventsService.find_by_id(event_id)

        case format
        when "pdf"
          generate_pdf(get_event, sold_tickets, summary, percentage, attendance_report)
        when "csv"
          generate_csv(get_event, sold_tickets, summary, percentage, attendance_report)
        when "json"
          generate_json(get_event, sold_tickets, summary, percentage, attendance_report)
        end
    else
        raise "Event not found"
    end
  end

  def self.generate_pdf(get_event, sold_tickets, summary, percentage, attendance_report)
    pdf = Prawn::Document.new
    pdf.text "Attendance Report", size: 24, style: :bold, align: :center
    pdf.move_down 20

    table_data = [
      [ "Attribute", "Value" ],  # Encabezado con atributo y valor
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
    pdf.render
  end

  def self.generate_csv(get_event, sold_tickets, summary, percentage, attendance_report)
    headers = [ "NAME", "DATE", "SOLD TICKETS", "TRUE ATTENDANCE", "FALSE ATTENDANCE", "PERCENTAGE" ]
    data = [ [ attendance_report.id, get_event["id"], get_event["name"], get_event["date"], sold_tickets, summary["true_attendees"], summary["false_attendees"], percentage ] ]

    CSV.generate(headers: true) do |csv|
      csv << headers
      data.each { |row| csv << row }
    end
  end

  def self.generate_json(get_event, sold_tickets, summary, percentage, attendance_report)
    { id: attendance_report.id, name: get_event["name"], event_id: get_event["id"], date: get_event["date"], sold_tickets: sold_tickets, true_attendees: summary["true_attendees"], false_attendees: summary["false_attendees"], percentage: percentage }
  end

  ATTENDANCE_URL = "#{ENV.fetch("ATTENDANCE_URL")}"
  def self.get_attendance_summary(event_id:)
    uri = URI("#{ATTENDANCE_URL}/events/#{event_id}/attendees/summary/assistants")
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end
end
