class CreateTicketReports < ActiveRecord::Migration[7.2]
  def change
    create_table :ticket_reports do |t|
      t.integer :capacity

      t.timestamps
    end
  end
end
