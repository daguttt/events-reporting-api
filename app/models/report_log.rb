class ReportLog < ApplicationRecord
  belongs_to :report
  validates :user_id, presence: true
  enum :status, [ :created, :reviewed ]
end
