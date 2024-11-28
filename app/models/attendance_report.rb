class AttendanceReport < ApplicationRecord
  has_one :report, as: :reportable
end
