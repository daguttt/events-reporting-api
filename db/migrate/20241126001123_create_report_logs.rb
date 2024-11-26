class CreateReportLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :report_logs do |t|
      t.references :report, null: false, foreign_key: true
      t.integer :status
      t.integer :user_id

      t.timestamps
    end
  end
end
