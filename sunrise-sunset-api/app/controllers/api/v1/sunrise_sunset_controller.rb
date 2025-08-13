class Api::V1::SunriseSunsetController < ApplicationController
  before_action :validate_params, only: [:index]

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

    respond_to do |format|
      format.json
    end

  rescue => e
    puts "ERROR in index: #{e.class}: #{e.message}"
    puts e.backtrace.first(5)
    raise e  # Re-raise para ver o erro
  end

  def locations
    cache_expires_in = ENV.fetch('LOCATIONS_CACHE_EXPIRES_IN') { 3600 }.to_i
    cache_key = "recent_locations_v2:#{Date.current}"

    @locations = begin
      Rails.cache.fetch(cache_key, expires_in: cache_expires_in.seconds) do
        get_recent_locations
      end
    rescue => e
      Rails.logger.warn "Cache error, falling back to database: #{e.message}"
      get_recent_locations
    end

    @cached_at = Time.current

    respond_to do |format|
      format.json
    end
  end

  def health
    @health_data = {
      status: 'healthy',
      timestamp: Time.current,
      version: Rails.application.config.respond_to?(:app_version) ? Rails.application.config.app_version : '1.0.0'
    }

    respond_to do |format|
      format.json
    end
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

  def validate_params
    required_params = %w[location start_date end_date]
    missing_params = required_params.select { |param| params[param].blank? }

    if missing_params.any?
      @error = {
        status: 'error',
        error: 'missing_parameters',
        message: "Missing required parameters: #{missing_params.join(', ')}"
      }
      render 'error', status: :bad_request
      return
    end

    begin
      Date.parse(params[:start_date])
      Date.parse(params[:end_date])
    rescue ArgumentError
      @error = {
        status: 'error',
        error: 'invalid_date_format',
        message: 'Dates must be in YYYY-MM-DD format'
      }
      render 'error', status: :bad_request
    end
  end
end
