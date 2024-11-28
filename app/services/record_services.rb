

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

  def self.inspect_report(report_id, user_id)
    return { error: "user_id cannot be empty" } if user_id.blank?
    report = Report.find_by(id: report_id)
    return { error: "Report not found" } unless report
    case report.format&.downcase
    when "pdf"
      # generate_pdf(report)
    when "csv"
      # generate_csv(report)
    else
      return { message: "Format not supported" }
    end
    log = report.report_logs.create(status: :reviewed, user_id: user_id)
    {
      message: "Report processed successfully",
      report: report.as_json,
      log: log.as_json
    }
  end
end
