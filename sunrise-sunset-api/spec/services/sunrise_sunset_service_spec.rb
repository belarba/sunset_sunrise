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
      end

      context 'when no data exists in database' do
        before do
          # Mock API response for date range
          mock_api_response = {
            'status' => 'OK',
            'results' => [
              {
                'sunrise' => '2024-08-01T05:30:00+00:00',
                'sunset' => '2024-08-01T19:45:00+00:00',
                'solar_noon' => '2024-08-01T12:37:30+00:00',
                'day_length' => '14:15:00',
                'utc_offset' => 0
              },
              {
                'sunrise' => '2024-08-02T05:31:00+00:00',
                'sunset' => '2024-08-02T19:44:00+00:00',
                'solar_noon' => '2024-08-02T12:37:30+00:00',
                'day_length' => '14:13:00',
                'utc_offset' => 0
              },
              {
                'sunrise' => '2024-08-03T05:32:00+00:00',
                'sunset' => '2024-08-03T19:43:00+00:00',
                'solar_noon' => '2024-08-03T12:37:30+00:00',
                'day_length' => '14:11:00',
                'utc_offset' => 0
              }
            ]
          }

          allow(described_class).to receive(:get).and_return(
            double(success?: true, parsed_response: mock_api_response)
          )
        end

        it 'makes single API call for date range' do
          expect(described_class).to receive(:get).once.with(
            "/json",
            hash_including(
              query: hash_including(
                lat: mock_location.latitude,
                lng: mock_location.longitude,
                date_start: '2024-08-01',
                date_end: '2024-08-03'
              )
            )
          )

          described_class.fetch_data(location, start_date, end_date)
        end

        it 'returns sunrise sunset data for date range' do
          result = described_class.fetch_data(location, start_date, end_date)

          expect(result).to be_an(Array)
          expect(result.size).to eq(3)
          expect(result.first).to be_a(SunriseSunsetData)
          expect(result.map(&:date)).to contain_exactly(
            Date.parse('2024-08-01'),
            Date.parse('2024-08-02'),
            Date.parse('2024-08-03')
          )
        end

        it 'creates all records in database' do
          expect {
            described_class.fetch_data(location, start_date, end_date)
          }.to change(SunriseSunsetData, :count).by(3)
        end
      end

      context 'when some data exists in database' do
        before do
          # Create existing data for middle date
          create(:sunrise_sunset_data,
            location: mock_location,
            date: Date.parse('2024-08-02')
          )

          # Mock API responses for missing date ranges
          mock_api_response_1 = {
            'status' => 'OK',
            'results' => {
              'sunrise' => '2024-08-01T05:30:00+00:00',
              'sunset' => '2024-08-01T19:45:00+00:00',
              'solar_noon' => '2024-08-01T12:37:30+00:00',
              'day_length' => '14:15:00',
              'utc_offset' => 0
            }
          }

          mock_api_response_3 = {
            'status' => 'OK',
            'results' => {
              'sunrise' => '2024-08-03T05:32:00+00:00',
              'sunset' => '2024-08-03T19:43:00+00:00',
              'solar_noon' => '2024-08-03T12:37:30+00:00',
              'day_length' => '14:11:00',
              'utc_offset' => 0
            }
          }

          allow(described_class).to receive(:get)
            .with("/json", hash_including(query: hash_including(date_start: '2024-08-01', date_end: '2024-08-01')))
            .and_return(double(success?: true, parsed_response: mock_api_response_1))

          allow(described_class).to receive(:get)
            .with("/json", hash_including(query: hash_including(date_start: '2024-08-03', date_end: '2024-08-03')))
            .and_return(double(success?: true, parsed_response: mock_api_response_3))
        end

        it 'makes API calls only for missing dates' do
          expect(described_class).to receive(:get).twice # For two missing date ranges

          result = described_class.fetch_data(location, start_date, end_date)
          expect(result.size).to eq(3)
        end

        it 'returns combined data (cached + new)' do
          result = described_class.fetch_data(location, start_date, end_date)

          expect(result.size).to eq(3)
          expect(result.map(&:date)).to contain_exactly(
            Date.parse('2024-08-01'),
            Date.parse('2024-08-02'),
            Date.parse('2024-08-03')
          )
        end

        it 'creates only missing records' do
          expect {
            described_class.fetch_data(location, start_date, end_date)
          }.to change(SunriseSunsetData, :count).by(2) # Only missing dates
        end
      end

      context 'when all data exists in database' do
        before do
          # Create all data
          (Date.parse(start_date)..Date.parse(end_date)).each do |date|
            create(:sunrise_sunset_data,
              location: mock_location,
              date: date
            )
          end
        end

        it 'does not make any API calls' do
          expect(described_class).not_to receive(:get)

          result = described_class.fetch_data(location, start_date, end_date)
          expect(result.size).to eq(3)
        end
      end

      context 'with non-contiguous missing dates' do
        before do
          # Create data for 1st and 3rd dates, missing 2nd
          create(:sunrise_sunset_data,
            location: mock_location,
            date: Date.parse('2024-08-01')
          )
          create(:sunrise_sunset_data,
            location: mock_location,
            date: Date.parse('2024-08-03')
          )

          # Mock API response for missing date
          mock_api_response = {
            'status' => 'OK',
            'results' => {
              'sunrise' => '2024-08-02T05:31:00+00:00',
              'sunset' => '2024-08-02T19:44:00+00:00',
              'solar_noon' => '2024-08-02T12:37:30+00:00',
              'day_length' => '14:13:00',
              'utc_offset' => 0
            }
          }

          allow(described_class).to receive(:get).and_return(
            double(success?: true, parsed_response: mock_api_response)
          )
        end

        it 'identifies and fetches only missing date' do
          expect(described_class).to receive(:get).once.with(
            "/json",
            hash_including(
              query: hash_including(
                date_start: '2024-08-02',
                date_end: '2024-08-02'
              )
            )
          )

          result = described_class.fetch_data(location, start_date, end_date)
          expect(result.size).to eq(3)
        end
      end
    end

    context 'with API returning array format' do
      let(:mock_location) { create(:location, :lisbon) }

      before do
        allow(Location).to receive(:find_or_create_by_search_term)
          .with(location).and_return(mock_location)

        # API retorna array de resultados
        mock_api_response = {
          'status' => 'OK',
          'results' => [
            {
              'sunrise' => '2024-08-01T05:30:00+00:00',
              'sunset' => '2024-08-01T19:45:00+00:00',
              'day_length' => '14:15:00'
            },
            {
              'sunrise' => '2024-08-02T05:31:00+00:00',
              'sunset' => '2024-08-02T19:44:00+00:00',
              'day_length' => '14:13:00'
            }
          ]
        }

        allow(described_class).to receive(:get).and_return(
          double(success?: true, parsed_response: mock_api_response)
        )
      end

      it 'handles array format correctly' do
        result = described_class.fetch_data(location, '2024-08-01', '2024-08-02')

        expect(result.size).to eq(2)
        expect(result.first.date).to eq(Date.parse('2024-08-01'))
        expect(result.second.date).to eq(Date.parse('2024-08-02'))
      end
    end

    context 'with API returning hash format (single day)' do
      let(:mock_location) { create(:location, :lisbon) }

      before do
        allow(Location).to receive(:find_or_create_by_search_term)
          .with(location).and_return(mock_location)

        # API retorna hash único (compatibilidade)
        mock_api_response = {
          'status' => 'OK',
          'results' => {
            'sunrise' => '2024-08-01T05:30:00+00:00',
            'sunset' => '2024-08-01T19:45:00+00:00',
            'day_length' => '14:15:00'
          }
        }

        allow(described_class).to receive(:get).and_return(
          double(success?: true, parsed_response: mock_api_response)
        )
      end

      it 'handles hash format correctly' do
        result = described_class.fetch_data(location, '2024-08-01', '2024-08-01')

        expect(result.size).to eq(1)
        expect(result.first.date).to eq(Date.parse('2024-08-01'))
      end
    end

    # Resto dos testes de erro permanecem iguais...
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

      it 'handles network timeouts' do
        allow(described_class).to receive(:get).and_raise(Timeout::Error)

        expect {
          described_class.fetch_data(location, start_date, end_date)
        }.to raise_error(described_class::ApiError, /request failed/)
      end

      it 'handles HTTP errors' do
        allow(described_class).to receive(:get).and_return(
          double(success?: false, code: 500)
        )

        expect {
          described_class.fetch_data(location, start_date, end_date)
        }.to raise_error(described_class::ApiError, /returned status 500/)
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

    describe '#find_missing_date_ranges' do
      let(:location) { create(:location, :lisbon) }

      it 'identifies single missing range at beginning' do
        existing_data = [
          create(:sunrise_sunset_data, location: location, date: Date.parse('2024-08-02')),
          create(:sunrise_sunset_data, location: location, date: Date.parse('2024-08-03'))
        ]

        ranges = service.send(:find_missing_date_ranges,
          location, Date.parse('2024-08-01'), Date.parse('2024-08-03'), existing_data)

        expect(ranges).to eq([
          { start_date: Date.parse('2024-08-01'), end_date: Date.parse('2024-08-01') }
        ])
      end

      it 'identifies single missing range at end' do
        existing_data = [
          create(:sunrise_sunset_data, location: location, date: Date.parse('2024-08-01')),
          create(:sunrise_sunset_data, location: location, date: Date.parse('2024-08-02'))
        ]

        ranges = service.send(:find_missing_date_ranges,
          location, Date.parse('2024-08-01'), Date.parse('2024-08-03'), existing_data)

        expect(ranges).to eq([
          { start_date: Date.parse('2024-08-03'), end_date: Date.parse('2024-08-03') }
        ])
      end

      it 'identifies single missing range in middle' do
        existing_data = [
          create(:sunrise_sunset_data, location: location, date: Date.parse('2024-08-01')),
          create(:sunrise_sunset_data, location: location, date: Date.parse('2024-08-03'))
        ]

        ranges = service.send(:find_missing_date_ranges,
          location, Date.parse('2024-08-01'), Date.parse('2024-08-03'), existing_data)

        expect(ranges).to eq([
          { start_date: Date.parse('2024-08-02'), end_date: Date.parse('2024-08-02') }
        ])
      end

      it 'identifies multiple missing ranges' do
        existing_data = [
          create(:sunrise_sunset_data, location: location, date: Date.parse('2024-08-02'))
        ]

        ranges = service.send(:find_missing_date_ranges,
          location, Date.parse('2024-08-01'), Date.parse('2024-08-05'), existing_data)

        expect(ranges).to eq([
          { start_date: Date.parse('2024-08-01'), end_date: Date.parse('2024-08-01') },
          { start_date: Date.parse('2024-08-03'), end_date: Date.parse('2024-08-05') }
        ])
      end

      it 'returns empty array when no missing dates' do
        existing_data = [
          create(:sunrise_sunset_data, location: location, date: Date.parse('2024-08-01')),
          create(:sunrise_sunset_data, location: location, date: Date.parse('2024-08-02')),
          create(:sunrise_sunset_data, location: location, date: Date.parse('2024-08-03'))
        ]

        ranges = service.send(:find_missing_date_ranges,
          location, Date.parse('2024-08-01'), Date.parse('2024-08-03'), existing_data)

        expect(ranges).to eq([])
      end

      it 'identifies entire range as missing' do
        existing_data = []

        ranges = service.send(:find_missing_date_ranges,
          location, Date.parse('2024-08-01'), Date.parse('2024-08-03'), existing_data)

        expect(ranges).to eq([
          { start_date: Date.parse('2024-08-01'), end_date: Date.parse('2024-08-03') }
        ])
      end
    end

    describe '#calculate_golden_hour_from_result' do
      it 'calculates golden hour correctly from sunset' do
        daily_result = {
          'sunset' => '2024-08-01T19:30:00+00:00'
        }

        result = service.send(:calculate_golden_hour_from_result, daily_result)
        expected_time = Time.parse('2024-08-01T19:30:00+00:00') - 1.hour

        expect(result).to eq(expected_time)
      end

      it 'returns nil when sunset is missing' do
        daily_result = {
          'sunset' => nil
        }

        result = service.send(:calculate_golden_hour_from_result, daily_result)
        expect(result).to be_nil
      end

      it 'returns nil when sunset is blank' do
        daily_result = {
          'sunset' => ''
        }

        result = service.send(:calculate_golden_hour_from_result, daily_result)
        expect(result).to be_nil
      end
    end

    describe '#create_sunrise_sunset_data_from_result' do
      let(:location) { create(:location, :lisbon) }
      let(:date) { Date.parse('2024-08-01') }
      let(:daily_result) do
        {
          'sunrise' => '2024-08-01T05:30:00+00:00',
          'sunset' => '2024-08-01T19:45:00+00:00',
          'solar_noon' => '2024-08-01T12:37:30+00:00',
          'day_length' => '14:15:00',
          'timezone' => 'UTC',
          'utc_offset' => 0
        }
      end

      it 'creates new record with correct attributes' do
        expect {
          service.send(:create_sunrise_sunset_data_from_result, daily_result, location, date)
        }.to change(SunriseSunsetData, :count).by(1)

        record = SunriseSunsetData.last
        expect(record.location).to eq(location)
        expect(record.date).to eq(date)
        expect(record.sunrise).to be_present
        expect(record.sunset).to be_present
        expect(record.day_length_seconds).to eq(51300) # 14:15:00 in seconds
      end

      it 'does not create duplicate records' do
        # Create first record
        service.send(:create_sunrise_sunset_data_from_result, daily_result, location, date)

        # Try to create duplicate
        expect {
          service.send(:create_sunrise_sunset_data_from_result, daily_result, location, date)
        }.not_to change(SunriseSunsetData, :count)
      end

      it 'handles missing sunrise/sunset gracefully' do
        polar_result = daily_result.merge({
          'sunrise' => nil,
          'sunset' => nil,
          'day_length' => '00:00:00'
        })

        record = service.send(:create_sunrise_sunset_data_from_result, polar_result, location, date)

        expect(record.sunrise).to be_nil
        expect(record.sunset).to be_nil
        expect(record.day_length_seconds).to eq(0)
      end
    end
  end

  describe 'integration scenarios' do
    let(:mock_location) { create(:location, :lisbon) }

    before do
      allow(Location).to receive(:find_or_create_by_search_term)
        .with(location).and_return(mock_location)
    end

    context 'with large date range optimization' do
      let(:start_date) { '2024-01-01' }
      let(:end_date) { '2024-01-10' }

      before do
        # Mock single API call for entire range
        mock_results = (1..10).map do |day|
          {
            'sunrise' => "2024-01-#{day.to_s.rjust(2, '0')}T07:00:00+00:00",
            'sunset' => "2024-01-#{day.to_s.rjust(2, '0')}T18:00:00+00:00",
            'day_length' => '11:00:00'
          }
        end

        mock_api_response = {
          'status' => 'OK',
          'results' => mock_results
        }

        allow(described_class).to receive(:get).and_return(
          double(success?: true, parsed_response: mock_api_response)
        )
      end

      it 'makes single API call for entire range' do
        expect(described_class).to receive(:get).once.with(
          "/json",
          hash_including(
            query: hash_including(
              date_start: '2024-01-01',
              date_end: '2024-01-10'
            )
          )
        )

        result = described_class.fetch_data(location, start_date, end_date)
        expect(result.size).to eq(10)
      end
    end

    context 'with mixed existing and missing data optimization' do
      let(:start_date) { '2024-01-01' }
      let(:end_date) { '2024-01-10' }

      before do
        # Create some existing data (days 1, 3, 7, 8, 10)
        [1, 3, 7, 8, 10].each do |day|
          create(:sunrise_sunset_data,
            location: mock_location,
            date: Date.parse("2024-01-#{day.to_s.rjust(2, '0')}")
          )
        end

        # Mock API calls for missing ranges
        # Range 1: days 2
        allow(described_class).to receive(:get)
          .with("/json", hash_including(query: hash_including(date_start: '2024-01-02', date_end: '2024-01-02')))
          .and_return(double(success?: true, parsed_response: {
            'status' => 'OK',
            'results' => { 'sunrise' => '2024-01-02T07:00:00+00:00', 'day_length' => '11:00:00' }
          }))

        # Range 2: days 4-6
        allow(described_class).to receive(:get)
          .with("/json", hash_including(query: hash_including(date_start: '2024-01-04', date_end: '2024-01-06')))
          .and_return(double(success?: true, parsed_response: {
            'status' => 'OK',
            'results' => [
              { 'sunrise' => '2024-01-04T07:00:00+00:00', 'day_length' => '11:00:00' },
              { 'sunrise' => '2024-01-05T07:00:00+00:00', 'day_length' => '11:00:00' },
              { 'sunrise' => '2024-01-06T07:00:00+00:00', 'day_length' => '11:00:00' }
            ]
          }))

        # Range 3: day 9
        allow(described_class).to receive(:get)
          .with("/json", hash_including(query: hash_including(date_start: '2024-01-09', date_end: '2024-01-09')))
          .and_return(double(success?: true, parsed_response: {
            'status' => 'OK',
            'results' => { 'sunrise' => '2024-01-09T07:00:00+00:00', 'day_length' => '11:00:00' }
          }))
      end

      it 'makes optimized API calls for missing ranges only' do
        expect(described_class).to receive(:get).exactly(3).times

        result = described_class.fetch_data(location, start_date, end_date)
        expect(result.size).to eq(10)

        # Verify all dates are present
        expected_dates = (Date.parse(start_date)..Date.parse(end_date)).to_a
        actual_dates = result.map(&:date).sort
        expect(actual_dates).to eq(expected_dates)
      end

      it 'creates only missing records' do
        expect {
          described_class.fetch_data(location, start_date, end_date)
        }.to change(SunriseSunsetData, :count).by(5) # Only missing dates
      end
    end

    context 'with error handling in batch operations' do
      around(:each) do |example|
        VCR.turned_off do
          WebMock.disable_net_connect!
          example.run
          WebMock.allow_net_connect!
        end
      end

      let(:start_date) { '2024-01-01' }
      let(:end_date) { '2024-01-03' }

      before do
        # Mock the first call (entire range) to fail
        allow(described_class).to receive(:get)
          .with("/json", hash_including(query: hash_including(date_start: '2024-01-01', date_end: '2024-01-03')))
          .and_raise(HTTParty::Error, 'Network error')
      end

      it 'handles API failures gracefully' do
        expect(Rails.logger).to receive(:error).with(/API request failed/)

        # Should raise ApiError since the entire range fetch failed
        expect {
          described_class.fetch_data(location, start_date, end_date)
        }.to raise_error(described_class::ApiError, /Sunrise-sunset API request failed/)
      end
    end

    context 'with partial error handling in mixed scenarios' do
      around(:each) do |example|
        VCR.turned_off do
          WebMock.disable_net_connect!
          example.run
          WebMock.allow_net_connect!
        end
      end

      let(:start_date) { '2024-01-01' }
      let(:end_date) { '2024-01-03' }

      before do
        # Create existing data for middle date to force multiple API calls
        create(:sunrise_sunset_data,
          location: mock_location,
          date: Date.parse('2024-01-02')
        )

        # Mock successful call for first missing range
        allow(described_class).to receive(:get)
          .with("/json", hash_including(query: hash_including(date_start: '2024-01-01', date_end: '2024-01-01')))
          .and_return(double(success?: true, parsed_response: {
            'status' => 'OK',
            'results' => {
              'sunrise' => '2024-01-01T07:00:00+00:00',
              'sunset' => '2024-01-01T18:00:00+00:00',
              'day_length' => '11:00:00'
            }
          }))

        # Mock failure for second missing range
        allow(described_class).to receive(:get)
          .with("/json", hash_including(query: hash_including(date_start: '2024-01-03', date_end: '2024-01-03')))
          .and_raise(HTTParty::Error, 'Network error')
      end
    end
  end
end
