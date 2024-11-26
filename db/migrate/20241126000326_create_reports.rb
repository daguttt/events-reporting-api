class CreateReports < ActiveRecord::Migration[7.2]
  def change
    create_table :reports do |t|
      t.datetime :date
      t.integer :event_id
      t.integer :format
      t.integer :sold_tickets
      t.references :reportable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
