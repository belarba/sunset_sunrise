class AddLocationReferenceToSunriseSunsetData < ActiveRecord::Migration[8.0]
  def up
    # Adicionar referência para location
    add_reference :sunrise_sunset_data, :location, null: true, foreign_key: true

    # Migrar dados existentes
    SunriseSunsetData.find_each do |data|
      location = Location.find_or_create_by(
        latitude: data.latitude,
        longitude: data.longitude
      ) do |loc|
        loc.name = data.location.split(',').first.strip
        loc.search_name = data.location.downcase.strip
        loc.display_name = data.location
        loc.country = data.location.split(',').last&.strip
      end

      data.update!(location: location)
    end

    # Após migração, tornar a referência obrigatória
    change_column_null :sunrise_sunset_data, :location_id, false
  end

  def down
    # Restaurar dados se necessário
    SunriseSunsetData.includes(:location).find_each do |data|
      data.update!(
        location: data.location.display_name,
        latitude: data.location.latitude,
        longitude: data.location.longitude
      )
    end

    remove_reference :sunrise_sunset_data, :location
  end
end
