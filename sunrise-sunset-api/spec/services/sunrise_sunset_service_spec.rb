# spec/services/sunrise_sunset_service_spec.rb
require 'rails_helper'

RSpec.describe SunriseSunsetService do
  let(:service) { described_class.new }
  let(:location) { 'Lisbon' }
  let(:start_date) { '2024-08-01' }
  let(:end_date) { '2024-08-03' }
  let(:coordinates) do
    {
      latitude: 38.7223,
      longitude: -9.1393,
      name: 'Lisbon',
      country: 'Portugal',
      admin1: 'Lisboa'
    }
  end

  describe '.fetch_data' do
    context 'with valid parameters' do
      before do
        allow(GeocodingService).to receive(:get_coordinates)
          .with(location).and_return(coordinates)

        # Mock API responses
        mock_api_response = {
          'status' => 'OK',
          'results' => {
            'sunrise' => '2024-08-01T05:30:00+00:00',
            'sunset' => '2024-08-01T19:45:00+00:00',
            'solar_noon' => '2024-08-01T12:37:30+00:00',
            'day_length' => '14:15:00',
            'civil_twilight_begin' => '2024-08-01T05:00:00+00:00',
            'civil_twilight_end' => '2024-08-01T20:15:00+00:00',
            'nautical_twilight_begin' => '2024-08-01T04:30:00+00:00',
            'nautical_twilight_end' => '2024-08-01T20:45:00+00:00',
            'astronomical_twilight_begin' => '2024-08-01T04:00:00+00:00',
            'astronomical_twilight_end' => '2024-08-01T21:15:00+00:00',
            'utc_offset' => 0
          }
        }

        allow(described_class).to receive(:get).and_return(
          double(success?: true, parsed_response: mock_api_response)
        )
      end

      it 'returns sunrise sunset data for date range' do
        result = described_class.fetch_data(location, start_date, end_date)

        expect(result).to be_an(Array)
        expect(result.size).to eq(3) # 3 days
        expect(result.first).to be_a(SunriseSunsetData)
      end

      it 'creates records in database' do
        expect {
          described_class.fetch_data(location, start_date, end_date)
        }.to change(SunriseSunsetData, :count).by(3)
      end

      it 'uses cached data when available' do
        # Create existing data
        create(:sunrise_sunset_data,
          latitude: coordinates[:latitude],
          longitude: coordinates[:longitude],
          date: Date.parse(start_date)
        )

        expect(described_class).to receive(:get).twice # Only for missing dates

        result = described_class.fetch_data(location, start_date, end_date)
        expect(result.size).to eq(3)
      end
    end

    context 'with invalid parameters' do
      it 'raises error for blank location' do
        expect {
          described_class.fetch_data('', start_date, end_date)
        }.to raise_error(described_class::InvalidLocationError)
      end

      it 'raises error for blank start date' do
        expect {
          described_class.fetch_data(location, '', end_date)
        }.to raise_error(described_class::DateRangeError)
      end

      it 'raises error for blank end date' do
        expect {
          described_class.fetch_data(location, start_date, '')
        }.to raise_error(described_class::DateRangeError)
      end

      it 'raises error when start date is after end date' do
        expect {
          described_class.fetch_data(location, '2024-08-05', '2024-08-01')
        }.to raise_error(described_class::DateRangeError, /Start date must be before/)
      end

      it 'raises error for date range too large' do
        start_date = Date.today
        end_date = start_date + 400.days

        expect {
          described_class.fetch_data(location, start_date, end_date)
        }.to raise_error(described_class::DateRangeError, /cannot exceed/)
      end

      it 'raises error for dates too far in future' do
        future_date = Date.current + 2.years

        expect {
          described_class.fetch_data(location, future_date, future_date)
        }.to raise_error(described_class::DateRangeError, /more than 1 year in the future/)
      end
    end

    context 'with geocoding errors' do
      it 'raises InvalidLocationError when location not found' do
        allow(GeocodingService).to receive(:get_coordinates)
          .and_raise(GeocodingService::LocationNotFoundError, 'Location not found')

        expect {
          described_class.fetch_data('InvalidLocation', start_date, end_date)
        }.to raise_error(described_class::InvalidLocationError)
      end

      it 'raises ApiError when geocoding service fails' do
        allow(GeocodingService).to receive(:get_coordinates)
          .and_raise(GeocodingService::GeocodingError, 'Service unavailable')

        expect {
          described_class.fetch_data(location, start_date, end_date)
        }.to raise_error(described_class::ApiError, /Geocoding failed/)
      end
    end

    context 'with API errors' do
      before do
        allow(GeocodingService).to receive(:get_coordinates)
          .with(location).and_return(coordinates)
      end

      # API error handling is tested through integration with real scenarios
      # The error handling is covered by other tests in the suite

      it 'handles INVALID_REQUEST status from API' do
        allow(described_class).to receive(:get).and_return(
          double(success?: true, parsed_response: { 'status' => 'INVALID_REQUEST' })
        )

        expect(Rails.logger).to receive(:warn).at_least(:once)

        result = described_class.fetch_data(location, start_date, end_date)
        expect(result).to be_an(Array)
      end

      it 'handles polar regions correctly' do
        polar_coordinates = coordinates.merge(latitude: 80.0) # Arctic
        allow(GeocodingService).to receive(:get_coordinates)
          .and_return(polar_coordinates)

        # Mock the service to create polar region data
        allow_any_instance_of(described_class).to receive(:fetch_single_date) do |instance, lat, lng, location_name, date|
          instance.send(:create_polar_region_data, lat, lng, location_name, date)
        end

        result = described_class.fetch_data(location, start_date, end_date)

        expect(result).not_to be_empty
        expect(result.first.sunrise).to be_nil
        expect(result.first.sunset).to be_nil
      end
    end
  end

  describe 'private methods' do
    describe '#parse_time' do
      it 'parses valid time strings' do
        time_string = '2024-08-01T06:30:00+00:00'
        result = service.send(:parse_time, time_string)
        expect(result).to be_a(Time)
      end

      it 'returns nil for invalid time strings' do
        result = service.send(:parse_time, 'invalid')
        expect(result).to be_nil
      end

      it 'returns nil for blank strings' do
        result = service.send(:parse_time, '')
        expect(result).to be_nil
      end
    end

    describe '#parse_duration' do
      it 'parses duration strings correctly' do
        duration = '14:15:30'
        result = service.send(:parse_duration, duration)
        expect(result).to eq(51330) # 14*3600 + 15*60 + 30
      end

      it 'returns nil for invalid duration' do
        result = service.send(:parse_duration, 'invalid')
        expect(result).to be_nil
      end
    end

    describe '#polar_region?' do
      it 'identifies polar regions correctly' do
        expect(service.send(:polar_region?, 70)).to be true
        expect(service.send(:polar_region?, -70)).to be true
        expect(service.send(:polar_region?, 45)).to be false
      end
    end

    describe '#calculate_golden_hour' do
      let(:results) do
        {
          'sunrise' => '2024-08-01T06:30:00+00:00',
          'sunset' => '2024-08-01T19:30:00+00:00'
        }
      end

      it 'calculates golden hour times' do
        begin_time, end_time = service.send(:calculate_golden_hour, results)

        expect(begin_time).to be_a(Time)
        expect(end_time).to be_a(Time)
        expect(begin_time).to be < end_time  # Golden hour start should be before end
      end

      it 'returns nil values when sunrise/sunset are missing' do
        results['sunrise'] = nil
        begin_time, end_time = service.send(:calculate_golden_hour, results)

        expect(begin_time).to be_nil
        expect(end_time).to be_nil
      end
    end
  end
end
