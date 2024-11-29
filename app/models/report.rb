class Report < ApplicationRecord
  validates :date, presence: true
  validates :event_id, presence: true, numericality: true
  validates :format, presence: true, inclusion: { in: [ "pdf", "csv", "json" ] }
  validates :sold_tickets, presence: true, numericality: true


  belongs_to :reportable, polymorphic: true
  has_many :report_logs
  enum :format, [ :pdf, :csv, :json ]
end
