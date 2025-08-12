class CreateSunriseSunsetData < ActiveRecord::Migration[8.0]
  def change
    create_table :sunrise_sunset_data do |t|
      t.string :location, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.date :date, null: false
      t.time :sunrise
      t.time :sunset
      t.time :solar_noon
      t.integer :day_length_seconds
      t.time :golden_hour
      t.string :timezone
      t.integer :utc_offset
      t.json :raw_api_data

      t.timestamps
    end

    add_index :sunrise_sunset_data, [:latitude, :longitude, :date],
              unique: true,
              name: 'index_sunrise_sunset_data_on_location_and_date'
    add_index :sunrise_sunset_data, :location
    add_index :sunrise_sunset_data, :date
  end
end
