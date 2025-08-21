class Api::V1::SunriseSunsetController < ApplicationController
  before_action :validate_params, only: [ :index ]

  def index
    @data = SunriseSunsetService.fetch_data(
      params[:location],
      params[:start_date],
      params[:end_date]
    )

    @meta = {
      location: params[:location],
      start_date: params[:start_date],
      end_date: params[:end_date],
      total_days: @data.size,
      cached_records: @data.count { |record| record.created_at < 1.minute.ago }
    }

    render json: {
      status: "success",
      data: @data.map do |record|
        {
          id: record.id,
          location: record.location_name,
          latitude: record.latitude.to_f,
          longitude: record.longitude.to_f,
          date: record.date,
          sunrise: record.sunrise&.strftime("%H:%M:%S"),
          sunset: record.sunset&.strftime("%H:%M:%S"),
          solar_noon: record.solar_noon&.strftime("%H:%M:%S"),
          day_length_seconds: record.day_length_seconds,
          day_length_formatted: record.day_length_formatted,
          golden_hour: record.golden_hour&.strftime("%H:%M:%S"),
          timezone: record.timezone,
          utc_offset: record.utc_offset,
          polar_day: record.polar_day?,
          polar_night: record.polar_night?,
          created_at: record.created_at.iso8601,
          updated_at: record.updated_at.iso8601
        }
      end,
      meta: @meta.merge(generated_at: Time.current.iso8601)
    }

  rescue SunriseSunsetService::InvalidLocationError => e
    render json: {
      status: "error",
      error: "invalid_location",
      message: e.message,
      timestamp: Time.current.iso8601
    }, status: :unprocessable_content

  rescue SunriseSunsetService::DateRangeError => e
    render json: {
      status: "error",
      error: "invalid_date_range",
      message: e.message,
      timestamp: Time.current.iso8601
    }, status: :unprocessable_content

  rescue SunriseSunsetService::ApiError => e
    render json: {
      status: "error",
      error: "api_error",
      message: e.message,
      timestamp: Time.current.iso8601
    }, status: :service_unavailable

  rescue StandardError => e
    Rails.logger.error "Internal server error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    render json: {
      status: "error",
      error: "internal_error",
      message: "An unexpected error occurred",
      timestamp: Time.current.iso8601
    }, status: :internal_server_error
  end

  def locations
    cache_expires_in = ENV.fetch("LOCATIONS_CACHE_EXPIRES_IN") { 3600 }.to_i
    cache_key = "recent_locations_v4:#{Date.current}"

    @locations = begin
      Rails.cache.fetch(cache_key, expires_in: cache_expires_in.seconds) do
        get_recent_locations
      end
    rescue => e
      Rails.logger.warn "Cache error, falling back to database: #{e.message}"
      get_recent_locations
    end

    render json: {
      status: "success",
      locations: @locations,
      total_count: @locations.size,
      cached_at: Time.current.iso8601,
      cache_expires_in: cache_expires_in
    }
  end

  def health
    database_status = begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      { status: "connected" }
    rescue => e
      { status: "error", message: e.message }
    end

    render json: {
      status: "healthy",
      version: Rails.application.config.respond_to?(:app_version) ? Rails.application.config.app_version : "1.0.0",
      timestamp: Time.current.iso8601,
      uptime_info: {
        rails_env: Rails.env,
        ruby_version: RUBY_VERSION,
        rails_version: Rails.version
      },
      database_status: database_status
    }
  end

  private

  def get_recent_locations
    # CORRIGIDO: Query SQL simplificada para evitar o erro do PostgreSQL
    ActiveRecord::Base.clear_active_connections! if ActiveRecord::Base.connection.transaction_open?

    # Usar um LEFT JOIN e subconsulta para resolver o problema do ORDER BY com DISTINCT
    recent_location_ids = SunriseSunsetData
      .joins(:location)
      .select("locations.id, MAX(sunrise_sunset_data.created_at) as last_used")
      .group("locations.id")
      .order("sunrise_sunset_data.created_at DESC")
      .limit(20)
      .pluck("locations.id")

    # Buscar os display_names das locations encontradas, mantendo a ordem
    if recent_location_ids.any?
      locations_hash = Location.where(id: recent_location_ids)
                              .pluck(:id, :display_name)
                              .to_h

      recent_location_ids.filter_map { |id| locations_hash[id] }
    else
      []
    end
  rescue => e
    Rails.logger.error "Database error in locations: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    []
  end

  def validate_params
    required_params = %w[location start_date end_date]
    missing_params = required_params.select { |param| params[param].blank? }

    if missing_params.any?
      render json: {
        status: "error",
        error: "missing_parameters",
        message: "Missing required parameters: #{missing_params.join(', ')}",
        timestamp: Time.current.iso8601
      }, status: :bad_request
      return
    end

    begin
      Date.parse(params[:start_date])
      Date.parse(params[:end_date])
    rescue ArgumentError
      render json: {
        status: "error",
        error: "invalid_date_format",
        message: "Dates must be in YYYY-MM-DD format",
        timestamp: Time.current.iso8601
      }, status: :bad_request
    end
  end
end
