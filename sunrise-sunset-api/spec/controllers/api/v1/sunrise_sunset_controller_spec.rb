# spec/controllers/api/v1/sunrise_sunset_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::SunriseSunsetController, type: :controller do
  let(:valid_location) { 'Lisbon' }
  let(:start_date) { '2024-08-01' }
  let(:end_date) { '2024-08-03' }
  let(:valid_params) { { location: valid_location, start_date: start_date, end_date: end_date } }

  describe 'GET #index' do
    context 'with valid parameters' do
      let(:mock_data) do
        [
          create(:sunrise_sunset_data,
                 date: Date.parse(start_date),
                 latitude: 38.7223,
                 longitude: -9.1393,
                 location: 'Lisbon, Portugal',
                 sunrise: Time.parse('06:30:00 UTC'),
                 sunset: Time.parse('19:45:00 UTC'),
                 day_length_seconds: 47700,
                 created_at: 2.hours.ago),
          create(:sunrise_sunset_data,
                 date: Date.parse(start_date) + 1.day,
                 latitude: 38.7223,
                 longitude: -9.1393,
                 location: 'Lisbon, Portugal',
                 sunrise: Time.parse('06:31:00 UTC'),
                 sunset: Time.parse('19:44:00 UTC'),
                 day_length_seconds: 47580,
                 created_at: 1.hour.ago),
          create(:sunrise_sunset_data,
                 date: Date.parse(end_date),
                 latitude: 38.7223,
                 longitude: -9.1393,
                 location: 'Lisbon, Portugal',
                 sunrise: Time.parse('06:32:00 UTC'),
                 sunset: Time.parse('19:43:00 UTC'),
                 day_length_seconds: 47460,
                 created_at: 30.minutes.ago)
        ]
      end

      before do
        allow(SunriseSunsetService).to receive(:fetch_data)
          .with(valid_location, start_date, end_date)
          .and_return(mock_data)
      end

      it 'returns successful response' do
        get :index, params: valid_params
        expect(response).to have_http_status(:success)
      end

      it 'returns correct JSON structure with JBuilder' do
        get :index, params: valid_params
        json_response = JSON.parse(response.body)

        # Basic structure
        expect(json_response).to have_key('status')
        expect(json_response).to have_key('data')
        expect(json_response).to have_key('meta')
        expect(json_response['status']).to eq('success')

        # Data array structure
        expect(json_response['data']).to be_an(Array)
        expect(json_response['data'].size).to eq(3)

        # First record structure
        first_record = json_response['data'].first
        expect(first_record).to have_key('id')
        expect(first_record).to have_key('location')
        expect(first_record).to have_key('latitude')
        expect(first_record).to have_key('longitude')
        expect(first_record).to have_key('date')
        expect(first_record).to have_key('sunrise')
        expect(first_record).to have_key('sunset')
        expect(first_record).to have_key('day_length_formatted')
        expect(first_record).to have_key('polar_day')
        expect(first_record).to have_key('polar_night')
        expect(first_record).to have_key('created_at')
        expect(first_record).to have_key('updated_at')

        # Data validation
        expect(first_record['location']).to eq('Lisbon, Portugal')
        expect(first_record['latitude']).to eq(38.7223)
        expect(first_record['longitude']).to eq(-9.1393)
        expect(first_record['sunrise']).to eq('06:30:00')
        expect(first_record['sunset']).to eq('19:45:00')
        expect(first_record['polar_day']).to be_falsey
        expect(first_record['polar_night']).to be_falsey
        expect(first_record['day_length_formatted']).to eq('13h 15m')
      end

      it 'includes comprehensive meta information' do
        get :index, params: valid_params
        json_response = JSON.parse(response.body)
        meta = json_response['meta']

        expect(meta['location']).to eq(valid_location)
        expect(meta['start_date']).to eq(start_date)
        expect(meta['end_date']).to eq(end_date)
        expect(meta['total_days']).to eq(3)
        expect(meta['cached_records']).to eq(3) # All records are older than 1 minute
        expect(meta).to have_key('generated_at')
        expect(meta['generated_at']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
      end

      it 'formats times correctly' do
        get :index, params: valid_params
        json_response = JSON.parse(response.body)

        first_record = json_response['data'].first
        expect(first_record['sunrise']).to match(/\d{2}:\d{2}:\d{2}/)
        expect(first_record['sunset']).to match(/\d{2}:\d{2}:\d{2}/)

        if first_record['solar_noon']
          expect(first_record['solar_noon']).to match(/\d{2}:\d{2}:\d{2}/)
        end
      end

      it 'includes ISO8601 timestamps' do
        get :index, params: valid_params
        json_response = JSON.parse(response.body)

        first_record = json_response['data'].first
        expect(first_record['created_at']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
        expect(first_record['updated_at']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
      end
    end

    context 'with missing parameters' do
      it 'returns error for missing location' do
        get :index, params: { start_date: start_date, end_date: end_date }
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['error']).to eq('missing_parameters')
        expect(json_response['message']).to include('location')
        expect(json_response).to have_key('timestamp')
      end

      it 'returns error for missing dates' do
        get :index, params: { location: valid_location }
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['error']).to eq('missing_parameters')
        expect(json_response['message']).to include('start_date', 'end_date')
      end

      it 'returns error for invalid date format' do
        get :index, params: { location: valid_location, start_date: 'invalid', end_date: end_date }
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['error']).to eq('invalid_date_format')
        expect(json_response['message']).to include('YYYY-MM-DD')
        expect(json_response).to have_key('timestamp')
      end
    end

    context 'with service errors' do
      it 'handles invalid location error' do
        allow(SunriseSunsetService).to receive(:fetch_data)
          .and_raise(SunriseSunsetService::InvalidLocationError, 'Location not found')

        get :index, params: valid_params
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['error']).to eq('invalid_location')
        expect(json_response['message']).to eq('Location not found')
        expect(json_response).to have_key('timestamp')
      end

      it 'handles date range error' do
        allow(SunriseSunsetService).to receive(:fetch_data)
          .and_raise(SunriseSunsetService::DateRangeError, 'Invalid date range')

        get :index, params: valid_params
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['error']).to eq('invalid_date_range')
        expect(json_response['message']).to eq('Invalid date range')
        expect(json_response).to have_key('timestamp')
      end

      it 'handles API error' do
        allow(SunriseSunsetService).to receive(:fetch_data)
          .and_raise(SunriseSunsetService::ApiError, 'API unavailable')

        get :index, params: valid_params
        expect(response).to have_http_status(:service_unavailable)

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['error']).to eq('api_error')
        expect(json_response['message']).to eq('API unavailable')
        expect(json_response).to have_key('timestamp')
      end

      it 'handles unexpected errors' do
        allow(SunriseSunsetService).to receive(:fetch_data)
          .and_raise(StandardError, 'Unexpected error')

        get :index, params: valid_params
        expect(response).to have_http_status(:internal_server_error)

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['error']).to eq('internal_error')
        expect(json_response['message']).to eq('An unexpected error occurred')
        expect(json_response).to have_key('timestamp')
      end
    end
  end

  describe 'GET #locations' do
    before do
      # Create test data with proper timestamps for caching tests
      create(:sunrise_sunset_data,
             location: 'Lisbon, Portugal',
             latitude: 38.7223,
             longitude: -9.1393,
             date: Date.current,
             created_at: 1.hour.ago)
      create(:sunrise_sunset_data,
             location: 'Berlin, Germany',
             latitude: 52.5200,
             longitude: 13.4050,
             date: Date.current,
             created_at: 2.hours.ago)
    end

    it 'returns recent locations with JBuilder structure' do
      get :locations
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq('success')
      expect(json_response['locations']).to be_an(Array)
      expect(json_response['locations'].size).to eq(2)
      expect(json_response['locations']).to include('Lisbon, Portugal', 'Berlin, Germany')

      # JBuilder specific fields
      expect(json_response).to have_key('total_count')
      expect(json_response['total_count']).to eq(2)
      expect(json_response).to have_key('cached_at')
      expect(json_response['cached_at']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
      expect(json_response).to have_key('cache_expires_in')
      expect(json_response['cache_expires_in']).to be_a(Integer)
    end

    it 'handles empty locations gracefully' do
      SunriseSunsetData.delete_all

      get :locations
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq('success')
      expect(json_response['locations']).to eq([])
      expect(json_response['total_count']).to eq(0)
    end

    it 'handles database errors gracefully' do
      allow(SunriseSunsetData).to receive(:select).and_raise(StandardError.new("Database error"))

      get :locations
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq('success')
      expect(json_response['locations']).to eq([])
      expect(json_response['total_count']).to eq(0)
    end
  end

  describe 'GET #health' do
    it 'returns health status with JBuilder structure' do
      get :health
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq('healthy')
      expect(json_response['version']).to eq('1.0.0')
      expect(json_response).to have_key('timestamp')
      expect(json_response['timestamp']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)

      # JBuilder specific fields
      expect(json_response).to have_key('uptime_info')
      expect(json_response['uptime_info']).to have_key('rails_env')
      expect(json_response['uptime_info']).to have_key('ruby_version')
      expect(json_response['uptime_info']).to have_key('rails_version')
      expect(json_response['uptime_info']['rails_env']).to eq('test')

      expect(json_response).to have_key('database_status')
      expect(json_response['database_status']).to have_key('status')
      expect(json_response['database_status']['status']).to eq('connected')
    end

    it 'handles database connection errors in health check' do
      allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(StandardError.new("DB Error"))

      get :health
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response['database_status']['status']).to eq('error')
      expect(json_response['database_status']['message']).to eq('DB Error')
    end
  end

  describe 'Content-Type headers' do
    it 'returns JSON content type for all endpoints' do
      get :health
      expect(response.content_type).to include('application/json')

      get :locations
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'Caching behavior' do
    it 'uses cache for locations endpoint' do
      # First request
      get :locations
      first_response = JSON.parse(response.body)

      # Create new data
      create(:sunrise_sunset_data, location: 'Madrid, Spain')

      # Second request should return cached data (not include Madrid)
      get :locations
      second_response = JSON.parse(response.body)

      expect(first_response['locations']).to eq(second_response['locations'])
    end
  end
end
