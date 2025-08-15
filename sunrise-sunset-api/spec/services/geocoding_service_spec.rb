require 'rails_helper'

RSpec.describe GeocodingService do
  # Remove o mock global para este teste específico
  before do
    allow(GeocodingService).to receive(:get_coordinates).and_call_original
  end

  describe '.get_coordinates', :vcr do
    context 'with valid location' do
      it 'returns coordinates for Lisbon', vcr: { cassette_name: 'geocoding/lisbon_success' } do
        result = described_class.get_coordinates('Lisbon')

        expect(result).to include(
          :latitude, :longitude, :name, :country
        )
        expect(result[:latitude]).to be_a(Numeric)
        expect(result[:longitude]).to be_a(Numeric)
        expect(result[:name]).to eq('Lisbon')
      end

      it 'returns coordinates for Berlin', vcr: { cassette_name: 'geocoding/berlin_success' } do
        result = described_class.get_coordinates('Berlin')

        expect(result[:name]).to eq('Berlin')
        expect(result[:country]).to eq('Germany')
      end
    end

    context 'with invalid location' do
      it 'raises LocationNotFoundError for non-existent location',
         vcr: { cassette_name: 'geocoding/invalid_location' } do
        expect {
          described_class.get_coordinates('InvalidLocationXYZ123')
        }.to raise_error(GeocodingService::LocationNotFoundError)
      end
    end

    context 'with API errors' do
      before do
        # Mock para simular falha de rede
        allow(described_class).to receive(:get).and_raise(HTTParty::Error)
      end

      it 'raises GeocodingError on network failure' do
        expect {
          described_class.get_coordinates('Lisbon')
        }.to raise_error(GeocodingService::GeocodingError)
      end
    end

    context 'caching behavior' do
      it 'caches successful responses' do
        # Primeiro, limpa o cache
        Rails.cache.clear

        # Mock para contar chamadas
        call_count = 0
        allow(described_class).to receive(:get) do |*args|
          call_count += 1
          double(
            success?: true,
            parsed_response: {
              'results' => [
                {
                  'latitude' => 38.7223,
                  'longitude' => -9.1393,
                  'name' => 'Lisbon',
                  'country' => 'Portugal'
                }
              ]
            }
          )
        end

        # Faz duas chamadas para a mesma localização
        described_class.get_coordinates('Lisbon')
        described_class.get_coordinates('Lisbon')

        # Deve ter chamado a API apenas uma vez
        expect(call_count).to eq(1)
      end
    end
  end

  describe 'error handling' do
    before do
      # Remove o mock global para estes testes
      allow(GeocodingService).to receive(:get_coordinates).and_call_original
    end

    context 'when API returns error status' do
      before do
        allow(described_class).to receive(:get).and_return(
          double(success?: false, code: 500)
        )
      end

      it 'raises GeocodingError' do
        expect {
          described_class.get_coordinates('Lisbon')
        }.to raise_error(GeocodingService::GeocodingError, /Geocoding API request failed/)
      end
    end

    context 'when API returns empty results' do
      before do
        allow(described_class).to receive(:get).and_return(
          double(success?: true, parsed_response: { 'results' => [] })
        )
      end

      it 'raises LocationNotFoundError' do
        expect {
          described_class.get_coordinates('NonExistentPlace')
        }.to raise_error(GeocodingService::LocationNotFoundError)
      end
    end
  end
end
