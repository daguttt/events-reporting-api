class TicketReport < ApplicationRecord
  has_one :report, as: :reportable
end
