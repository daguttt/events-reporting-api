require "net/http"
class AttendanceService
  ATTENDANCE_URL = "#{ENV.fetch("ATTENDANCE_URL")}"
  def self.create_report(params)
    # event_id = params[:event_id]
    # format = params[:format]
    event_id = 2
    format = "pdf"
    summary = get_attendance_summary(event_id: event_id)
    sold_tickets = summary["true_attendees"] + summary["false_attendees"]
    percentage = summary["true_attendees"] * 100 / sold_tickets

    attendance_report = AttendanceReport.create(percentage: percentage)
    attendance_report.create_report(
      date: Time.now,
      event_id: 2,
      format: format,
      sold_tickets: sold_tickets
    )

    attendance_report.report.report_logs.create(
      status: :created
    )
    # if @attendance_report.save
    #   type = params[:type]
    #   case type
    #   when "pdf"

    #   when "csv"

    #   when "json"
    #   end
    # else
    # end
  end

  def self.get_attendance_summary(event_id:)
    # uri = URI("#{ATTENDACE_URL}/events/#{event_id}/attendees/summary/assistants")
    # response = Net::HTTP.get_response(uri)
    # JSON.parse(response.body)
    # 50 -> 100%
    # 5 -> X
    {
      "true_attendees" => 20,
      "false_attendees" => 30
    }
  end

  private
end
