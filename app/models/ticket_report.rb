class TicketReport < ApplicationRecord
  validates :capacity, presence: true, numericality: true
  has_one :report, as: :reportable
end
