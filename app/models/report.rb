class Report < ApplicationRecord
  before_validation :validate_format

  validates :date, presence: true, format: {
    with: /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z\z/,
    message: "debe tener el formato ISO 8601 (YYYY-MM-DDTHH:MM:SS.sssZ)"
  }
  validates :event_id, presence: true, numericality: true
  validates :format, presence: true
  validates :sold_tickets, presence: true, numericality: true


  belongs_to :reportable, polymorphic: true
  has_many :report_logs
  enum :format, [ :pdf, :csv, :json ]

  def validate_format
    unless Report.formats.include?(:format)
      errors.add(:format, "must be pdf, json or csv")
      errors.each do |error|
        puts "Error: #{error.full_message}" # Opción rápida (no usar en producción)
      end
    end
  end
end
