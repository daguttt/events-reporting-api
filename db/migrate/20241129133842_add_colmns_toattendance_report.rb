class AddColmnsToattendanceReport < ActiveRecord::Migration[7.2]
  def change
    add_column :attendance_reports, :true_attendees, :integer, null: false
    add_column :attendance_reports, :false_attendees, :integer, null: false
  end
end
