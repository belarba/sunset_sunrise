require 'rails_helper'

RSpec.describe 'External APIs Integration', type: :integration do
  describe 'Complete flow with real APIs', :vcr do
    it 'successfully geocodes location and fetches sunrise data',
       vcr: { cassette_name: 'integration/complete_flow_lisbon' } do

      # Esta é uma chamada completa sem mocks
      VCR.use_cassette('integration/complete_flow_lisbon') do
        result = SunriseSunsetService.fetch_data('Lisbon', '2024-08-01', '2024-08-01')

        expect(result).to be_an(Array)
        expect(result.size).to eq(1)

        record = result.first
        expect(record.location.name).to eq('Lisbon')
        expect(record.latitude).to be_between(38, 39)
        expect(record.longitude).to be_between(-10, -9)
        expect(record.sunrise).to be_present
        expect(record.sunset).to be_present
      end
    end

    it 'handles network failures gracefully' do
      # Simula falha de rede desabilitando VCR
      VCR.turned_off do
        WebMock.disable_net_connect!

        expect {
          SunriseSunsetService.fetch_data('Lisbon', '2024-08-01', '2024-08-01')
        }.to raise_error(SunriseSunsetService::ApiError)

        WebMock.allow_net_connect!
      end
    end
  end
end
