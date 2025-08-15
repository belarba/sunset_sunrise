class GeocodingService
  include HTTParty
  base_uri ENV.fetch("GEOCODING_API_URL") { "https://geocoding-api.open-meteo.com/v1" }

  class GeocodingError < StandardError; end
  class LocationNotFoundError < StandardError; end

  CACHE_EXPIRES_IN = ENV.fetch("GEOCODING_CACHE_EXPIRES_IN") { 604800 }.to_i # 1 week
  API_TIMEOUT = ENV.fetch("API_TIMEOUT") { 10 }.to_i

  def self.get_coordinates(location)
    new.get_coordinates(location)
  end

  def get_coordinates(location)
    Rails.cache.fetch("geocoding:#{location.downcase}", expires_in: CACHE_EXPIRES_IN.seconds) do
      fetch_coordinates(location)
    end
  end

  private

  def fetch_coordinates(location)
    response = self.class.get("/search", {
      query: {
        name: location,
        count: 1,
        language: "en",
        format: "json"
      },
      timeout: API_TIMEOUT
    })

    handle_response(response, location)
  end

  def handle_response(response, location)
    raise GeocodingError, "Geocoding API request failed" unless response.success?

    results = response.parsed_response["results"]
    raise LocationNotFoundError, "Location '#{location}' not found" if results.blank?

    result = results.first
    {
      latitude: result["latitude"],
      longitude: result["longitude"],
      name: result["name"],
      country: result["country"],
      admin1: result["admin1"]
    }
  rescue HTTParty::Error, Timeout::Error => e
    Rails.logger.error "Geocoding service error: #{e.message}"
    raise GeocodingError, "Failed to geocode location: #{e.message}"
  end
end
