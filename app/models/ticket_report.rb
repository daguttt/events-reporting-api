class TicketReport < ApplicationRecord
  has_many :reports, as: :reportable
end
