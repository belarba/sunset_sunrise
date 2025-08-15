module ApiTestHelpers
  def stub_geocoding_success(location: 'Lisbon', coordinates: { latitude: 38.7223, longitude: -9.1393 })
    allow(GeocodingService).to receive(:get_coordinates)
      .with(location)
      .and_return({
        latitude: coordinates[:latitude],
        longitude: coordinates[:longitude],
        name: location,
        country: 'Portugal',
        admin1: 'Lisboa'
      })
  end

  def stub_geocoding_failure(location: 'InvalidLocation', error: GeocodingService::LocationNotFoundError)
    allow(GeocodingService).to receive(:get_coordinates)
      .with(location)
      .and_raise(error, "Location '#{location}' not found")
  end

  def stub_sunrise_sunset_success(date: '2024-08-01')
    mock_response = {
      'status' => 'OK',
      'results' => {
        'sunrise' => "#{date}T06:30:00+00:00",
        'sunset' => "#{date}T19:45:00+00:00",
        'solar_noon' => "#{date}T13:07:30+00:00",
        'day_length' => '13:15:00',
        'golden_hour' => "#{date}T18:45:00+00:00",
        'timezone' => 'UTC',
        'utc_offset' => 0
      }
    }

    allow(SunriseSunsetService).to receive(:get)
      .and_return(double(success?: true, parsed_response: mock_response))
  end

  def stub_sunrise_sunset_failure(error_status: 'INVALID_REQUEST')
    mock_response = { 'status' => error_status }

    allow(SunriseSunsetService).to receive(:get)
      .and_return(double(success?: true, parsed_response: mock_response))
  end

  def with_real_http
    VCR.turned_off do
      WebMock.allow_net_connect!
      yield
      WebMock.disable_net_connect!(allow_localhost: true)
    end
  end
end
