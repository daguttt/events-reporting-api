# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_29_133842) do
  create_table "attendance_reports", force: :cascade do |t|
    t.float "percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "true_attendees", null: false
    t.integer "false_attendees", null: false
  end

  create_table "report_logs", force: :cascade do |t|
    t.integer "report_id", null: false
    t.integer "status"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_report_logs_on_report_id"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "date"
    t.integer "event_id"
    t.integer "format"
    t.integer "sold_tickets"
    t.string "reportable_type", null: false
    t.integer "reportable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable"
  end

  create_table "ticket_reports", force: :cascade do |t|
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "report_logs", "reports"
end
