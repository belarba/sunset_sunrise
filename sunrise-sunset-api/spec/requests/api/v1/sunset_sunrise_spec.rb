require 'rails_helper'

RSpec.describe "Sunrise Sunset API", type: :request do
  describe "GET /api/v1/sunrise_sunset" do
    let(:valid_params) do
      {
        location: 'Lisbon',
        start_date: '2024-08-01',
        end_date: '2024-08-03'
      }
    end

    context "with valid parameters" do
      let(:mock_location) { create(:location, :lisbon) }

      before do
        allow(SunriseSunsetService).to receive(:fetch_data).and_return([
          create(:sunrise_sunset_data, date: Date.parse('2024-08-01'), location: mock_location),
          create(:sunrise_sunset_data, date: Date.parse('2024-08-02'), location: mock_location),
          create(:sunrise_sunset_data, date: Date.parse('2024-08-03'), location: mock_location)
        ])
      end

      it "returns successful response with correct structure" do
        get "/api/v1/sunrise_sunset", params: valid_params

        expect(response).to have_http_status(:success)

        json = JSON.parse(response.body)
        expect(json).to include('status', 'data', 'meta')
        expect(json['status']).to eq('success')
        expect(json['data']).to be_an(Array)
        expect(json['data'].size).to eq(3)
      end

      it "includes proper meta information" do
        get "/api/v1/sunrise_sunset", params: valid_params

        json = JSON.parse(response.body)
        meta = json['meta']

        expect(meta['location']).to eq('Lisbon')
        expect(meta['total_days']).to eq(3)
        expect(meta).to have_key('cached_records')
      end
    end

    context "with invalid parameters" do
      it "returns error for missing location" do
        get "/api/v1/sunrise_sunset", params: valid_params.except(:location)

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('missing_parameters')
      end
    end
  end

  describe "GET /health" do
    it "returns health status" do
      get "/health"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['status']).to eq('healthy')
    end
  end
end
