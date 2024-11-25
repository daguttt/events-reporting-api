class CreateReports < ActiveRecord::Migration[7.2]
  def change
    create_table :reports do |t|
      t.datetime :date
      t.integer :event_id
      t.integer :user_id
      t.integer :format
      t.integer :type

      t.timestamps
    end
  end
end
