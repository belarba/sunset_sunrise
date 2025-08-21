require 'rails_helper'

RSpec.describe SunriseSunsetService do
  let(:service) { described_class.new }
  let(:location) { 'Lisbon' }
  let(:start_date) { '2024-08-01' }
  let(:end_date) { '2024-08-03' }

  describe '.fetch_data' do
    context 'with valid parameters' do
      let(:mock_location) { create(:location, :lisbon) }

      before do
        allow(Location).to receive(:find_or_create_by_search_term)
          .with(location).and_return(mock_location)

        # Mock API responses
        mock_api_response = {
          'status' => 'OK',
          'results' => {
            'sunrise' => '2024-08-01T05:30:00+00:00',
            'sunset' => '2024-08-01T19:45:00+00:00',
            'solar_noon' => '2024-08-01T12:37:30+00:00',
            'day_length' => '14:15:00',
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
        expect(result.size).to eq(3)
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
          location: mock_location,
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

    context 'with location errors' do
      it 'raises InvalidLocationError when location not found' do
        allow(Location).to receive(:find_or_create_by_search_term)
          .and_raise(GeocodingService::LocationNotFoundError, 'Location not found')

        expect {
          described_class.fetch_data('InvalidLocation', start_date, end_date)
        }.to raise_error(described_class::InvalidLocationError)
      end

      it 'raises ApiError when geocoding service fails' do
        allow(Location).to receive(:find_or_create_by_search_term)
          .and_raise(GeocodingService::GeocodingError, 'Service unavailable')

        expect {
          described_class.fetch_data(location, start_date, end_date)
        }.to raise_error(described_class::ApiError, /Geocoding failed/)
      end
    end

    context 'with API errors' do
      let(:mock_location) { create(:location, :lisbon) }

      before do
        allow(Location).to receive(:find_or_create_by_search_term)
          .with(location).and_return(mock_location)
      end

      it 'handles INVALID_REQUEST status from API' do
        allow(described_class).to receive(:get).and_return(
          double(success?: true, parsed_response: { 'status' => 'INVALID_REQUEST' })
        )

        expect(Rails.logger).to receive(:warn).at_least(:once)

        result = described_class.fetch_data(location, start_date, end_date)
        expect(result).to be_an(Array)
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
        expect(result).to eq(51330)
      end

      it 'returns nil for invalid duration' do
        result = service.send(:parse_duration, 'invalid')
        expect(result).to be_nil
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
        expect(begin_time).to be < end_time
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
