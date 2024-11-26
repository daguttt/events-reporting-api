class AttendanceReport < ApplicationRecord
  has_many :reports, as: :reportable
end
