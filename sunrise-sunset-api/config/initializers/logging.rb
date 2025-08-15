if Rails.env.production?
  Rails.application.configure do
    # Structured logging for production
    config.log_formatter = proc do |severity, timestamp, progname, msg|
      {
        timestamp: timestamp.iso8601,
        level: severity,
        message: msg,
        service: "sunrise-sunset-api"
      }.to_json + "\n"
    end
  end
end
