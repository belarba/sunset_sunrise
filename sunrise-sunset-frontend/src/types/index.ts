export interface SunriseSunsetData {
  id: number;
  location: string;
  latitude: number;
  longitude: number;
  date: string;
  sunrise: string | null;
  sunset: string | null;
  solar_noon: string | null;
  day_length_seconds: number;
  day_length_formatted: string;
  golden_hour: string | null;
  timezone: string;
  utc_offset: number;
  polar_day: boolean;
  polar_night: boolean;
  created_at: string;
  updated_at: string;
}

export interface ApiResponse {
  status: 'success' | 'error';
  data?: SunriseSunsetData[];
  meta?: {
    location: string;
    start_date: string;
    end_date: string;
    total_days: number;
    cached_records: number;
    generated_at: string;
  };
  error?: string;
  message?: string;
  timestamp?: string;
}

export interface SearchForm {
  location: string;
  start_date: string;
  end_date: string;
}

export interface LocationsResponse {
  status: 'success';
  locations: string[];
  total_count: number;
  cached_at: string;
  cache_expires_in: number;
}

export interface HealthResponse {
  status: 'healthy' | 'unhealthy';
  version: string;
  timestamp: string;
  uptime_info: {
    rails_env: string;
    ruby_version: string;
    rails_version: string;
  };
  database_status: {
    status: 'connected' | 'error';
    message?: string;
  };
}