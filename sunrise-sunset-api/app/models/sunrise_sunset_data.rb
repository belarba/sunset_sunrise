class SunriseSunsetData < ApplicationRecord
  validates :location, presence: true
  validates :latitude, presence: true,
            numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true,
            numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :date, presence: true
  validates :latitude, uniqueness: { scope: [:longitude, :date] }

  scope :by_location, ->(lat, lng) { where(latitude: lat, longitude: lng) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :recent, -> { order(date: :desc) }

  def self.find_or_fetch_data(latitude, longitude, location, date)
    existing_data = find_by(latitude: latitude, longitude: longitude, date: date)
    return existing_data if existing_data

    # If data doesn't exist, it will be fetched by the service
    nil
  end

  def day_length_formatted
    return nil unless day_length_seconds

    hours = day_length_seconds / 3600
    minutes = (day_length_seconds % 3600) / 60
    "#{hours}h #{minutes}m"
  end

  def polar_day?
    sunrise.nil? && sunset.nil? && day_length_seconds && day_length_seconds >= 86400
  end

  def polar_night?
    sunrise.nil? && sunset.nil? && day_length_seconds && day_length_seconds <= 0
  end

  def as_json(options = {})
    super(options.merge(
      methods: [:day_length_formatted, :polar_day?, :polar_night?],
      except: [:raw_api_data]
    ))
  end
end
