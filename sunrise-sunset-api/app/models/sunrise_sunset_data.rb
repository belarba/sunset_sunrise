class SunriseSunsetData < ApplicationRecord
  belongs_to :location

  validates :date, presence: true
  validates :location_id, uniqueness: { scope: :date }

  scope :by_location, ->(location) { where(location: location) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :recent, -> { order(date: :desc) }

  delegate :latitude, :longitude, :display_name, :polar_region?, to: :location
  alias_method :location_name, :display_name

  def self.find_or_fetch_data(location, date)
    existing_data = joins(:location)
                   .where(locations: { id: location.id }, date: date)
                   .first
    return existing_data if existing_data

    # Se não existe, retorna nil - será criado pelo service
    nil
  end

  def day_length_formatted
    return nil unless day_length_seconds

    hours = day_length_seconds / 3600
    minutes = (day_length_seconds % 3600) / 60
    "#{hours}h #{minutes}m"
  end

  def polar_day?
    polar_summer_period? if sunrise.nil? && sunset.nil? && day_length_seconds && day_length_seconds >= 86400
  end

  def polar_night?
    polar_winter_period? if sunrise.nil? && sunset.nil? && day_length_seconds && day_length_seconds <= 0
  end

  def polar_summer_period?
    return false unless location.polar_region?

    month = date.month
    if latitude > 0  # Hemisfério Norte
      [5, 6, 7, 8].include?(month)  # Maio a Agosto
    else  # Hemisfério Sul
      [11, 12, 1, 2].include?(month)  # Novembro a Fevereiro
    end
  end

  def polar_winter_period?
    return false unless location.polar_region?

    month = date.month
    if latitude > 0  # Hemisfério Norte
      [11, 12, 1, 2].include?(month)  # Novembro a Fevereiro
    else  # Hemisfério Sul
      [5, 6, 7, 8].include?(month)  # Maio a Agosto
    end
  end

  def as_json(options = {})
    super(options.merge(
      methods: [ :day_length_formatted, :polar_day?, :polar_night?, :latitude, :longitude, :location_name ],
      except: [ :raw_api_data ]
    ))
  end
end
