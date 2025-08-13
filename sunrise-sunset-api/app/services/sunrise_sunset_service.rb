class SunriseSunsetService
  include HTTParty
  base_uri ENV.fetch('SUNRISE_SUNSET_API_URL') { 'https://api.sunrisesunset.io' }

  class ApiError < StandardError; end
  class InvalidLocationError < StandardError; end
  class DateRangeError < StandardError; end

  MAX_DATE_RANGE_DAYS = ENV.fetch('MAX_DATE_RANGE_DAYS') { 365 }.to_i
  API_TIMEOUT = ENV.fetch('API_TIMEOUT') { 15 }.to_i

  def self.fetch_data(location_name, start_date, end_date)
    new.fetch_data(location_name, start_date, end_date)
  end

  def fetch_data(location_name, start_date, end_date)
    validate_inputs(location_name, start_date, end_date)

    # Encontra ou cria location (com geocoding apenas se necessário)
    location = find_or_create_location(location_name)

    fetch_date_range(location, start_date, end_date)
  end

  private

  def validate_inputs(location_name, start_date, end_date)
    raise InvalidLocationError, "Location cannot be blank" if location_name.blank?
    raise DateRangeError, "Start date cannot be blank" if start_date.blank?
    raise DateRangeError, "End date cannot be blank" if end_date.blank?

    start_date = Date.parse(start_date.to_s) unless start_date.is_a?(Date)
    end_date = Date.parse(end_date.to_s) unless end_date.is_a?(Date)

    raise DateRangeError, "Start date must be before or equal to end date" if start_date > end_date

    date_range = (end_date - start_date).to_i + 1
    if date_range > MAX_DATE_RANGE_DAYS
      raise DateRangeError, "Date range cannot exceed #{MAX_DATE_RANGE_DAYS} days (requested: #{date_range})"
    end

    if start_date < Date.new(1900, 1, 1)
      raise DateRangeError, "Cannot fetch data for dates before 1900"
    end

    if start_date > Date.current + 1.year
      raise DateRangeError, "Cannot fetch data for dates more than 1 year in the future"
    end
  end

  def find_or_create_location(location_name)
    # Esta operação agora só faz geocoding se a location não existir
    Location.find_or_create_by_search_term(location_name)
  rescue GeocodingService::LocationNotFoundError => e
    raise InvalidLocationError, e.message
  rescue GeocodingService::GeocodingError => e
    raise ApiError, "Geocoding failed: #{e.message}"
  end

  def fetch_date_range(location, start_date, end_date)
    start_date = Date.parse(start_date.to_s) unless start_date.is_a?(Date)
    end_date = Date.parse(end_date.to_s) unless end_date.is_a?(Date)

    results = []
    missing_dates = []

    (start_date..end_date).each do |date|
      existing_data = SunriseSunsetData.find_or_fetch_data(location, date)

      if existing_data
        results << existing_data
      else
        missing_dates << date
      end
    end

    # Fetch missing dates from API
    unless missing_dates.empty?
      Rails.logger.info "Fetching #{missing_dates.size} missing dates from API for #{location.display_name}"

      missing_dates.each do |date|
        begin
          data = fetch_single_date(location, date)
          results << data if data
        rescue => e
          Rails.logger.error "Failed to fetch data for #{date}: #{e.message}"
          # Continue with other dates even if one fails
        end
      end
    end

    results.sort_by(&:date)
  end

  def fetch_single_date(location, date)
    response = self.class.get('/json', {
      query: {
        lat: location.latitude,
        lng: location.longitude,
        date: date.strftime('%Y-%m-%d')
      },
      timeout: API_TIMEOUT
    })

    handle_api_response(response, location, date)
  rescue HTTParty::Error, Timeout::Error => e
    Rails.logger.error "API request failed: #{e.message}"
    raise ApiError, "Sunrise-sunset API request failed: #{e.message}"
  end

  def handle_api_response(response, location, date)
    unless response.success?
      raise ApiError, "API returned status #{response.code}"
    end

    data = response.parsed_response

    if data['status'] != 'OK'
      handle_api_error(data, location, date)
      return nil
    end

    create_sunrise_sunset_data(data, location, date)
  end

  def handle_api_error(data, location, date)
    case data['status']
    when 'INVALID_REQUEST'
      Rails.logger.warn "Invalid request for #{location.display_name} on #{date}"
    when 'INVALID_DATE'
      Rails.logger.warn "Invalid date #{date} for #{location.display_name}"
    when 'UNKNOWN_ERROR'
      Rails.logger.error "Unknown error from API for #{location.display_name} on #{date}"
    end

    # For polar regions, create a record with nil values
    if polar_region?(location.latitude)
      create_polar_region_data(location, date)
    end
  end

  def create_sunrise_sunset_data(api_data, location, date)
    results = api_data['results']

    SunriseSunsetData.create!(
      location: location,
      date: date,
      sunrise: parse_time_simple(results['sunrise']),
      sunset: parse_time_simple(results['sunset']),
      solar_noon: parse_time_simple(results['solar_noon']),
      day_length_seconds: parse_duration(results['day_length']),
      golden_hour: parse_time_simple(results['golden_hour']),
      timezone: results['timezone'],
      utc_offset: results['utc_offset'],
      raw_api_data: api_data
    )
  end

  def create_polar_region_data(location, date)
    # For polar regions where sun doesn't rise/set
    SunriseSunsetData.create!(
      location: location,
      date: date,
      sunrise: nil,
      sunset: nil,
      solar_noon: nil,
      day_length_seconds: polar_day_length(location.latitude, date),
      golden_hour: nil,
      timezone: nil,
      utc_offset: nil,
      raw_api_data: { status: 'POLAR_REGION', latitude: location.latitude, longitude: location.longitude, date: date }
    )
  end

  def calculate_golden_hour(results)
    sunrise = parse_time(results['sunrise'])
    sunset = parse_time(results['sunset'])

    return [nil, nil] unless sunrise && sunset

    golden_hour_begin = sunrise + 1.hour  # Start 1 hour after sunrise
    golden_hour_end = sunset - 1.hour     # End 1 hour before sunset

    [golden_hour_begin, golden_hour_end]
  end

  def parse_time_simple(time_string)
    return nil if time_string.blank?

    if time_string.match?(/^\d{1,2}:\d{2}:\d{2}\s?(AM|PM)$/i)
      Time.parse(time_string)
    elsif time_string.match?(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
      Time.parse(time_string)
    else
      Time.parse(time_string)
    end
  rescue ArgumentError => e
    Rails.logger.warn "Failed to parse time '#{time_string}': #{e.message}"
    nil
  end

  # Alias para compatibilidade com testes
  def parse_time(time_string)
    parse_time_simple(time_string)
  end

  def parse_duration(duration_string)
    return nil if duration_string.blank?

    parts = duration_string.split(':')
    return nil unless parts.length == 3

    hours = parts[0].to_i
    minutes = parts[1].to_i
    seconds = parts[2].to_i

    (hours * 3600) + (minutes * 60) + seconds
  rescue
    nil
  end

  def polar_region?(latitude)
    latitude.abs >= 66.5
  end

  def polar_day_length(latitude, date)
    return 86400 if polar_summer?(latitude, date)  # 24 hours
    return 0 if polar_winter?(latitude, date)      # 0 hours
    nil # Transition periods
  end

  def polar_summer?(latitude, date)
    month = date.month
    if latitude > 0  # Northern hemisphere
      [5, 6, 7, 8].include?(month)
    else  # Southern hemisphere
      [11, 12, 1, 2].include?(month)
    end
  end

  def polar_winter?(latitude, date)
    month = date.month
    if latitude > 0  # Northern hemisphere
      [11, 12, 1, 2].include?(month)
    else  # Southern hemisphere
      [5, 6, 7, 8].include?(month)
    end
  end
end
