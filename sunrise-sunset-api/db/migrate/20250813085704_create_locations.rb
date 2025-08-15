class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :search_name, null: false # Nome usado na busca (normalizado)
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.string :country
      t.string :admin1 # Estado/Região
      t.string :display_name # Nome completo para exibição
      t.json :raw_geocoding_data

      t.timestamps
    end

    # Índices para performance
    add_index :locations, :search_name, unique: true
    add_index :locations, [ :latitude, :longitude ], unique: true
    add_index :locations, :name
  end
end
