class AddPerformanceIndexesToSunriseSunsetData < ActiveRecord::Migration[8.0]
  def change
    add_index :sunrise_sunset_data, [:date, :created_at], name: 'idx_date_created_performance'
    add_index :sunrise_sunset_data, [:location, :date], name: 'idx_location_date_lookup'
  end
end
