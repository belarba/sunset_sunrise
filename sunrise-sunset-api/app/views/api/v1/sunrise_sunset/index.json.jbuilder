json.status 'success'

json.data @data do |record|
  json.id record.id
  json.location record.location
  json.latitude record.latitude
  json.longitude record.longitude
  json.date record.date
  json.sunrise record.sunrise&.strftime('%H:%M:%S')
  json.sunset record.sunset&.strftime('%H:%M:%S')
  json.solar_noon record.solar_noon&.strftime('%H:%M:%S')
  json.day_length_seconds record.day_length_seconds
  json.day_length_formatted record.day_length_formatted
  json.golden_hour record.golden_hour&.strftime('%H:%M:%S')
  json.timezone record.timezone
  json.utc_offset record.utc_offset
  json.polar_day record.polar_day?
  json.polar_night record.polar_night?
  json.created_at record.created_at.iso8601
  json.updated_at record.updated_at.iso8601
end

json.meta do
  json.location @meta[:location]
  json.start_date @meta[:start_date]
  json.end_date @meta[:end_date]
  json.total_days @meta[:total_days]
  json.cached_records @meta[:cached_records]
  json.generated_at Time.current.iso8601
end
