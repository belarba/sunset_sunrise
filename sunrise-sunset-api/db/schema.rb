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

ActiveRecord::Schema[8.0].define(version: 2025_08_13_085902) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "search_name", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.string "country"
    t.string "admin1"
    t.string "display_name"
    t.json "raw_geocoding_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latitude", "longitude"], name: "index_locations_on_latitude_and_longitude", unique: true
    t.index ["name"], name: "index_locations_on_name"
    t.index ["search_name"], name: "index_locations_on_search_name", unique: true
  end

  create_table "sunrise_sunset_data", force: :cascade do |t|
    t.date "date", null: false
    t.time "sunrise"
    t.time "sunset"
    t.time "solar_noon"
    t.integer "day_length_seconds"
    t.time "golden_hour"
    t.string "timezone"
    t.integer "utc_offset"
    t.json "raw_api_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "location_id", null: false
    t.index ["date", "created_at"], name: "idx_date_created_performance"
    t.index ["date"], name: "index_sunrise_sunset_data_on_date"
    t.index ["location_id"], name: "index_sunrise_sunset_data_on_location_id"
  end

  add_foreign_key "sunrise_sunset_data", "locations"
end
