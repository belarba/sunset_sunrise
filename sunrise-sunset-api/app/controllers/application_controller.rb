class ApplicationController < ActionController::API
  include ActionController::Caching
  include ActionController::MimeResponds

  before_action :set_default_format
  before_action :log_request_info

  rescue_from StandardError, with: :handle_internal_error
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  private

  def set_default_format
    request.format = :json
  end

  def log_request_info
    Rails.logger.info "#{request.method} #{request.path} - Params: #{filtered_params}"
  end

  def filtered_params
    params.except(:controller, :action, :format)
  end

  def handle_parameter_missing(exception)
    render json: {
      status: 'error',
      error: 'missing_parameter',
      message: exception.message
    }, status: :bad_request
  end

  def handle_internal_error(exception)
    Rails.logger.error "Internal server error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    render json: {
      status: 'error',
      error: 'internal_server_error',
      message: 'An unexpected error occurred'
    }, status: :internal_server_error
  end
end
