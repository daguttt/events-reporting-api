

class RecordServices
  def self.get_logs
    logs = ReportLog.all.order(created_at: :desc)
    logs.as_json()
  end

  def self.get_reports
    reports = Report.all.order(created_at: :desc)
    reports_with_url = reports.map do |report|
      report.as_json.merge(get_report_file: "http://127.0.0.1:3000/reports/#{report.id}")
    end
    reports_with_url
  end

  def self.inspect_report(report_id, user_id)
    report = Report.find_by(id: report_id)
    if report
      case report.format&.downcase
      when "pdf"
        # generate_pdf(report)
      when "csv"
        # generate_csv(report)
      else
        return { message: "Format not supported" }
      end
    log = report.report_logs.create(status: :reviewed, user_id: user_id)
    else
      { error: "Report not found" }
    end
  end
end