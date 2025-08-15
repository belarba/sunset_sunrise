json.extract! @health_data, :status, :version
json.timestamp @health_data[:timestamp].iso8601

json.uptime_info do
  json.rails_env Rails.env
  json.ruby_version RUBY_VERSION
  json.rails_version Rails.version
end

json.database_status do
  begin
    ActiveRecord::Base.connection.execute("SELECT 1")
    json.status "connected"
  rescue => e
    json.status "error"
    json.message e.message
  end
end
