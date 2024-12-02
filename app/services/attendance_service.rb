require "net/http"
require "csv"
class AttendanceService
  ATTENDANCE_URL = ENV.fetch("ATTENDANCE_URL")
  def self.create_report(params)
    event_id = params[:event_id]
    format = params[:format]
    user_id = params[:user_id]
    summary = get_attendance_summary(event_id: event_id)
    sold_tickets = summary["true_attendees"] + summary["false_attendees"]
    percentage = sold_tickets == 0 ? 0 : summary["true_attendees"] * 100 / sold_tickets
    found_event = EventsService.find_by_id(event_id)
    if found_event != nil
      attendance_report = AttendanceReport.create(percentage: percentage)
      attendance_report.create_report(
        date: Time.now,
        event_id: event_id,
        format: format,
        sold_tickets: sold_tickets
      )

      attendance_report.report.report_logs.create(status: :created, user_id: user_id)

      case format
      when "pdf"
        { pdf_data: GenerateFilesServices.generate_pdf("attendance", report, event) }
      when "csv"
        { csv_data: GenerateFilesServices.generate_csv("attendance", report, event) }
      when "json"
        generate_json(event, sold_tickets, summary, percentage, attendance_report)
      end
    else
      raise "Event not found"
    end
  end


  def self.generate_json(get_event, sold_tickets, summary, percentage, attendance_report)
    { id: attendance_report.id, name: get_event["name"], event_id: get_event["id"], date: get_event["date"], sold_tickets: sold_tickets, true_attendees: summary["true_attendees"], false_attendees: summary["false_attendees"], percentage: percentage }
  end

  def self.get_attendance_summary(event_id:)
    uri = URI("#{ATTENDANCE_URL}/events/#{event_id}/attendees/summary/assistants")
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end
end
