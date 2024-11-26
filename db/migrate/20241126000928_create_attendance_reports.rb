class CreateAttendanceReports < ActiveRecord::Migration[7.2]
  def change
    create_table :attendance_reports do |t|
      t.float :percentage

      t.timestamps
    end
  end
end
