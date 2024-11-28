class Report < ApplicationRecord
  belongs_to :reportable, polymorphic: true
  has_many :report_logs
  enum :format, [ :pdf, :csv, :json ]
end
