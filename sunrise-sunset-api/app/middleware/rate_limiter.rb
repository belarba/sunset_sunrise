class RateLimiter
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if api_request?(request.path) && rate_limited?(request.ip)
      [429, { 'Content-Type' => 'application/json' },
       [{ status: 'error', message: 'Rate limit exceeded' }.to_json]]
    else
      @app.call(env)
    end
  end

  private

  def api_request?(path)
    path.start_with?('/api/')
  end

  def rate_limited?(ip)
    key = "rate_limit:#{ip}"
    count = Rails.cache.read(key) || 0

    if count >= 100 # 100 requests per hour
      true
    else
      Rails.cache.write(key, count + 1, expires_in: 1.hour)
      false
    end
  end
end
