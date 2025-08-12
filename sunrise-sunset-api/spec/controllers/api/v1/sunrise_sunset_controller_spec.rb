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
          create(:sunrise_sunset_data, date: Date.parse(start_date)),
          create(:sunrise_sunset_data, date: Date.parse(start_date) + 1.day),
          create(:sunrise_sunset_data, date: Date.parse(end_date))
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

      it 'returns correct JSON structure' do
        get :index, params: valid_params
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key('status')
        expect(json_response).to have_key('data')
        expect(json_response).to have_key('meta')
        expect(json_response['status']).to eq('success')
      end

      it 'includes meta information' do
        get :index, params: valid_params
        json_response = JSON.parse(response.body)
        meta = json_response['meta']

        expect(meta['location']).to eq(valid_location)
        expect(meta['start_date']).to eq(start_date)
        expect(meta['end_date']).to eq(end_date)
        expect(meta['total_days']).to eq(3)
      end
    end

    context 'with missing parameters' do
      it 'returns error for missing location' do
        get :index, params: { start_date: start_date, end_date: end_date }
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['error']).to eq('missing_parameters')
      end

      it 'returns error for missing dates' do
        get :index, params: { location: valid_location }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error for invalid date format' do
        get :index, params: { location: valid_location, start_date: 'invalid', end_date: end_date }
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('invalid_date_format')
      end
    end

    context 'with service errors' do
      it 'handles invalid location error' do
        allow(SunriseSunsetService).to receive(:fetch_data)
          .and_raise(SunriseSunsetService::InvalidLocationError, 'Location not found')

        get :index, params: valid_params
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('invalid_location')
      end

      it 'handles date range error' do
        allow(SunriseSunsetService).to receive(:fetch_data)
          .and_raise(SunriseSunsetService::DateRangeError, 'Invalid date range')

        get :index, params: valid_params
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('invalid_date_range')
      end

      it 'handles API error' do
        allow(SunriseSunsetService).to receive(:fetch_data)
          .and_raise(SunriseSunsetService::ApiError, 'API unavailable')

        get :index, params: valid_params
        expect(response).to have_http_status(:service_unavailable)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('api_error')
      end
    end
  end

  describe 'GET #locations' do
    before do
      create(:sunrise_sunset_data, location: 'Lisbon, Portugal')
      create(:sunrise_sunset_data, location: 'Berlin, Germany')
    end

    it 'returns recent locations' do
      get :locations
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq('success')
      expect(json_response['locations']).to be_an(Array)
    end
  end
end
