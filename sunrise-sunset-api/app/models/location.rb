class Location < ApplicationRecord
  has_many :sunrise_sunset_data, class_name: 'SunriseSunsetData', dependent: :destroy

  validates :name, presence: true
  validates :search_name, presence: true, uniqueness: true
  validates :latitude, presence: true,
            numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true,
            numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  scope :by_coordinates, ->(lat, lng) { where(latitude: lat, longitude: lng) }

  before_validation :normalize_search_name

  def self.find_or_create_by_search_term(search_term)
    normalized_term = normalize_search_term(search_term)

    # Primeiro tenta encontrar por nome de busca
    location = find_by(search_name: normalized_term)
    return location if location

    # Se não encontrar, faz geocoding e cria
    create_from_geocoding(search_term)
  end

  def self.create_from_geocoding(search_term)
    coordinates = GeocodingService.get_coordinates(search_term)

    # Verifica se já existe por coordenadas (tolerância para pequenas diferenças)
    existing = by_coordinates(coordinates[:latitude], coordinates[:longitude]).first
    if existing
      # Atualiza o search_name se necessário
      normalized_term = normalize_search_term(search_term)
      unless existing.search_name == normalized_term
        # Pode adicionar aliases ou manter o original
      end
      return existing
    end

    # Cria nova location
    create!(
      name: coordinates[:name],
      search_name: normalize_search_term(search_term),
      latitude: coordinates[:latitude],
      longitude: coordinates[:longitude],
      country: coordinates[:country],
      admin1: coordinates[:admin1],
      display_name: build_display_name(coordinates),
      raw_geocoding_data: coordinates
    )
  end

  def polar_region?
    latitude.abs >= 66.5
  end

  private

  def normalize_search_name
    self.search_name = self.class.normalize_search_term(name) if name.present?
  end

  def self.normalize_search_term(term)
    term.to_s.downcase.strip
  end

  def self.build_display_name(coordinates)
    parts = [coordinates[:name]]
    parts << coordinates[:admin1] if coordinates[:admin1].present?
    parts << coordinates[:country] if coordinates[:country].present?
    parts.join(', ')
  end
end
