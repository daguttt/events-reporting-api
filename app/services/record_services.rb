

class RecordServices
  def self.get_logs
    logs = ReportLog.all.order(created_at: :desc)
    if logs.empty?
      { message: "No logs available" }
    else
      logs.as_json
    end
  end

  def self.get_reports
    reports = Report.all.order(created_at: :desc)
    if reports.empty?
      { message: "No reports available" }
    else
      reports_with_url = reports.map do |report|
        report.as_json.merge(get_report_file: "http://127.0.0.1:3000/reports/#{report.id}")
      end
      reports_with_url
    end
  end

  def self.inspect_report(report, user_id, format)
    return { error: "user_id cannot be empty" } if user_id.blank?
    return { error: "Report not found" } unless report
    event = EventsService.find_by_id(report[:event_id])
    type = report.reportable_type

    case format
    when "pdf"
      if type == "AttendanceReport"
        data = GenerateFilesServices.generate_pdf("attendance", report, event)
      elsif type == "TicketReport"
        data = GenerateFilesServices.generate_pdf("tickets", report, event)
      end
    when "csv"
      puts "generando csv"
      if type == "AttendanceReport"
        data = GenerateFilesServices.generate_csv("attendance", report, event)
      elsif type == "TicketReport"
        data = GenerateFilesServices.generate_csv("tickets", report, event)
      end
    else
      return { message: "Format not supported" }
    end
    log = report.report_logs.create(status: :reviewed, user_id: user_id)
    {
      message: "Report processed successfully",
      report: report.as_json,
      log: log.as_json,
      data: data
    }
  end
end
