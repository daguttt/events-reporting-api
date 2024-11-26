class ReportLog < ApplicationRecord
  belongs_to :report
  enum :status, [ :created, :reviewed ]
end
