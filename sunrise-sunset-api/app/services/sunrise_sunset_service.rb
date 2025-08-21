class SunriseSunsetService
  include HTTParty
  base_uri ENV.fetch("SUNRISE_SUNSET_API_URL") { "https://api.sunrisesunset.io" }

  class ApiError < StandardError; end
  class InvalidLocationError < StandardError; end
  class DateRangeError < StandardError; end

  MAX_DATE_RANGE_DAYS = ENV.fetch("MAX_DATE_RANGE_DAYS") { 365 }.to_i
  API_TIMEOUT = ENV.fetch("API_TIMEOUT") { 15 }.to_i

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

    # Verifica quais dados já existem no banco
    existing_data = find_existing_data(location, start_date, end_date)

    # Se todos os dados já existem, retorna eles
    total_days = (end_date - start_date).to_i + 1
    if existing_data.count == total_days
      Rails.logger.info "All data found in cache for #{location.display_name} (#{total_days} days)"
      return existing_data.sort_by(&:date)
    end

    # Identifica gaps (datas em falta) para fazer request otimizado
    missing_date_ranges = find_missing_date_ranges(location, start_date, end_date, existing_data)

    if missing_date_ranges.any?
      Rails.logger.info "Fetching #{missing_date_ranges.sum { |r| (r[:end_date] - r[:start_date]).to_i + 1 }} missing dates from API for #{location.display_name}"

      # Faz requests para cada range contínuo em falta
      missing_date_ranges.each do |range|
        fetch_date_range_from_api(location, range[:start_date], range[:end_date])
      end
    end

    # Retorna todos os dados (existentes + novos) ordenados por data
    find_existing_data(location, start_date, end_date).sort_by(&:date)
  end

  def find_existing_data(location, start_date, end_date)
    SunriseSunsetData.joins(:location)
                     .where(locations: { id: location.id }, date: start_date..end_date)
                     .includes(:location)
  end

  def find_missing_date_ranges(location, start_date, end_date, existing_data)
    existing_dates = existing_data.map(&:date).to_set
    date_ranges = []
    current_range_start = nil

    (start_date..end_date).each do |date|
      if existing_dates.include?(date)
        # Se estava em um range, fecha ele
        if current_range_start
          date_ranges << {
            start_date: current_range_start,
            end_date: date - 1.day
          }
          current_range_start = nil
        end
      else
        # Se não estava em um range, inicia um novo
        current_range_start ||= date
      end
    end

    # Fecha o último range se necessário
    if current_range_start
      date_ranges << {
        start_date: current_range_start,
        end_date: end_date
      }
    end

    date_ranges
  end

  def fetch_date_range_from_api(location, start_date, end_date)
    response = self.class.get("/json", {
      query: {
        lat: location.latitude,
        lng: location.longitude,
        date_start: start_date.strftime("%Y-%m-%d"),
        date_end: end_date.strftime("%Y-%m-%d")
      },
      timeout: API_TIMEOUT
    })

    handle_date_range_api_response(response, location, start_date, end_date)
  rescue HTTParty::Error, Timeout::Error => e
    Rails.logger.error "API request failed: #{e.message}"
    raise ApiError, "Sunrise-sunset API request failed: #{e.message}"
  end

  def handle_date_range_api_response(response, location, start_date, end_date)
    unless response.success?
      raise ApiError, "API returned status #{response.code}"
    end

    data = response.parsed_response

    if data["status"] != "OK"
      handle_api_error(data, location, start_date, end_date)
      return
    end

    # A API retorna um array de resultados para date ranges
    results_array = data["results"]

    if results_array.is_a?(Array)
      # Formato de array com múltiplos resultados
      results_array.each_with_index do |daily_result, index|
        current_date = start_date + index.days
        create_sunrise_sunset_data_from_result(daily_result, location, current_date)
      end
    elsif results_array.is_a?(Hash)
      # Formato single result (compatibilidade com requests de um dia só)
      create_sunrise_sunset_data_from_result(results_array, location, start_date)
    else
      Rails.logger.error "Unexpected API response format: #{results_array.class}"
    end
  end

  def handle_api_error(data, location, start_date, end_date)
    case data["status"]
    when "INVALID_REQUEST"
      Rails.logger.warn "Invalid request for #{location.display_name} from #{start_date} to #{end_date}"
    when "INVALID_DATE"
      Rails.logger.warn "Invalid date range #{start_date} to #{end_date} for #{location.display_name}"
    when "UNKNOWN_ERROR"
      Rails.logger.error "Unknown error from API for #{location.display_name} from #{start_date} to #{end_date}"
    end
  end

  def create_sunrise_sunset_data_from_result(daily_result, location, date)
    # Evita duplicatas usando find_or_create_by
    SunriseSunsetData.find_or_create_by(
      location: location,
      date: date
    ) do |record|
      record.sunrise = parse_time_simple(daily_result["sunrise"])
      record.sunset = parse_time_simple(daily_result["sunset"])
      record.solar_noon = parse_time_simple(daily_result["solar_noon"])
      record.day_length_seconds = parse_duration(daily_result["day_length"])
      record.golden_hour = calculate_golden_hour_from_result(daily_result)
      record.timezone = daily_result["timezone"]
      record.utc_offset = daily_result["utc_offset"]
      record.raw_api_data = { daily_result: daily_result }
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create record for #{location.display_name} on #{date}: #{e.message}"
    nil
  end

  def calculate_golden_hour_from_result(daily_result)
    # Calcula golden hour baseado no sunset (1 hora antes)
    sunset = parse_time_simple(daily_result["sunset"])
    return nil unless sunset

    sunset - 1.hour
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

    parts = duration_string.split(":")
    return nil unless parts.length == 3

    hours = parts[0].to_i
    minutes = parts[1].to_i
    seconds = parts[2].to_i

    (hours * 3600) + (minutes * 60) + seconds
  rescue
    nil
  end
end
