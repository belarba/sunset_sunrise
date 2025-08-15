json.status "success"
json.locations @locations
json.total_count @locations.size
json.cached_at @cached_at.iso8601
json.cache_expires_in ENV.fetch("LOCATIONS_CACHE_EXPIRES_IN") { 3600 }.to_i
