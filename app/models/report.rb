class Report < ApplicationRecord
  enum :type [:attendance, :ticket_sales]
  enum :format [:pdf, :csv, :json]
end
