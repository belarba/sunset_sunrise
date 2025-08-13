class RemoveLocationFromSunriseSunsetData < ActiveRecord::Migration[8.0]
  def change
    remove_column :sunrise_sunset_data, :location, :string
    remove_column :sunrise_sunset_data, :latitude, :decimal
    remove_column :sunrise_sunset_data, :longitude, :decimal
  end
end
