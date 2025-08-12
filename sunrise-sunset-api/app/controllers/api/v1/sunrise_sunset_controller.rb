class Api::V1::SunriseSunsetController < ApplicationController
  before_action :validate_params, only: [:index]

  def index
    data = SunriseSunsetService.fetch_data(
      params[:location],
      params[:start_date],
      params[:end_date]
    )

    render json: {
      status: 'success',
      data: data,
      meta: {
        location: params[:location],
        start_date: params[:start_date],
        end_date: params[:end_date],
        total_days: data.size,
        cached_records: data.count { |record| record.created_at < 1.minute.ago }
      }
    }
  rescue SunriseSunsetService::InvalidLocationError => e
    render json: {
      status: 'error',
      error: 'invalid_location',
      message: e.message
    }, status: :unprocessable_content

  rescue SunriseSunsetService::DateRangeError => e
    render json: {
      status: 'error',
      error: 'invalid_date_range',
      message: e.message
    }, status: :unprocessable_content

  rescue SunriseSunsetService::ApiError => e
    render json: {
      status: 'error',
      error: 'api_error',
      message: e.message
    }, status: :service_unavailable

  rescue StandardError => e
    Rails.logger.error "Unexpected error in SunriseSunsetController: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    render json: {
      status: 'error',
      error: 'internal_error',
      message: 'An unexpected error occurred'
    }, status: :internal_server_error
  end

  def locations
    # Return recently searched locations for autocomplete
    cache_expires_in = ENV.fetch('LOCATIONS_CACHE_EXPIRES_IN') { 3600 }.to_i

    locations = begin
      if Rails.cache.respond_to?(:fetch)
        Rails.cache.fetch('recent_locations', expires_in: cache_expires_in.seconds) do
          get_recent_locations
        end
      else
        get_recent_locations
      end
    rescue => e
      Rails.logger.warn "Cache error, falling back to database: #{e.message}"
      get_recent_locations
    end

    render json: {
      status: 'success',
      locations: locations
    }
  end

  private

  def get_recent_locations
    SunriseSunsetData
      .select(:location)
      .distinct
      .order('MAX(created_at) DESC')
      .group(:location)
      .limit(20)
      .pluck(:location)
  rescue => e
    Rails.logger.error "Database error in locations: #{e.message}"
    []
  end

  def health
    render json: {
      status: 'healthy',
      timestamp: Time.current,
      version: Rails.application.config.respond_to?(:app_version) ? Rails.application.config.app_version : '1.0.0'
    }
  end

  private

  def validate_params
    required_params = %w[location start_date end_date]
    missing_params = required_params.select { |param| params[param].blank? }

    if missing_params.any?
      render json: {
        status: 'error',
        error: 'missing_parameters',
        message: "Missing required parameters: #{missing_params.join(', ')}"
      }, status: :bad_request
      return
    end

    # Validate date format
    begin
      Date.parse(params[:start_date])
      Date.parse(params[:end_date])
    rescue ArgumentError
      render json: {
        status: 'error',
        error: 'invalid_date_format',
        message: 'Dates must be in YYYY-MM-DD format'
      }, status: :bad_request
    end
  end
end
