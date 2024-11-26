class Report < ApplicationRecord
  belongs_to :reportable, polymorphic: true
  enum :format [:pdf, :csv, :json]
end
