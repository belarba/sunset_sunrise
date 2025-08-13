require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:valid_attributes) do
    {
      name: 'Lisbon',
      latitude: 38.7223,
      longitude: -9.1393,
      country: 'Portugal',
      display_name: 'Lisbon, Portugal'
    }
  end

  subject { described_class.new(valid_attributes) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it 'requires search_name and ensures uniqueness' do
      # O search_name é gerado automaticamente a partir do name
      subject.save!

      duplicate = described_class.new(valid_attributes)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:search_name]).to include('has already been taken')
    end

    it 'validates latitude range' do
      subject.latitude = 91
      expect(subject).not_to be_valid
      expect(subject.errors[:latitude]).to include('must be less than or equal to 90')

      subject.latitude = -91
      expect(subject).not_to be_valid
      expect(subject.errors[:latitude]).to include('must be greater than or equal to -90')
    end

    it 'validates longitude range' do
      subject.longitude = 181
      expect(subject).not_to be_valid
      expect(subject.errors[:longitude]).to include('must be less than or equal to 180')

      subject.longitude = -181
      expect(subject).not_to be_valid
      expect(subject.errors[:longitude]).to include('must be greater than or equal to -180')
    end
  end

  describe 'callbacks' do
    it 'normalizes search_name before validation' do
      location = described_class.new(name: 'New York City')
      location.valid?
      expect(location.search_name).to eq('new york city')
    end
  end

  describe 'scopes' do
    describe '.by_coordinates' do
      it 'finds locations by coordinates' do
        location = create(:location, latitude: 38.7223, longitude: -9.1393)
        results = described_class.by_coordinates(38.7223, -9.1393)
        expect(results).to include(location)
      end
    end
  end

  describe 'class methods' do
    describe '.find_or_create_by_search_term' do
      context 'when location exists' do
        it 'returns existing location' do
          existing = create(:location, name: 'Lisbon', search_name: 'lisbon')
          result = described_class.find_or_create_by_search_term('Lisbon')
          expect(result.id).to eq(existing.id)
          expect(result.name).to eq('Lisbon')
        end
      end

      context 'when location does not exist' do
        let(:geocoding_response) do
          {
            latitude: 38.7223,
            longitude: -9.1393,
            name: 'Lisbon',
            country: 'Portugal',
            admin1: 'Lisboa'
          }
        end

        before do
          allow(GeocodingService).to receive(:get_coordinates)
            .with('Lisbon').and_return(geocoding_response)
        end

        it 'creates new location from geocoding' do
          expect {
            described_class.find_or_create_by_search_term('Lisbon')
          }.to change(described_class, :count).by(1)
        end

        it 'returns location with correct attributes' do
          result = described_class.find_or_create_by_search_term('Lisbon')
          expect(result.name).to eq('Lisbon')
          expect(result.latitude).to eq(38.7223)
          expect(result.longitude).to eq(-9.1393)
          expect(result.country).to eq('Portugal')
        end
      end
    end

    describe '.normalize_search_term' do
      it 'normalizes search terms correctly' do
        expect(described_class.normalize_search_term('New York City')).to eq('new york city')
        expect(described_class.normalize_search_term('  LONDON  ')).to eq('london')
      end
    end
  end

  describe 'instance methods' do
    describe '#polar_region?' do
      it 'identifies polar regions correctly' do
        polar_location = create(:location, latitude: 70.0)
        normal_location = create(:location, latitude: 45.0)

        expect(polar_location.polar_region?).to be true
        expect(normal_location.polar_region?).to be false
      end
    end
  end

  describe 'associations' do
    it 'has many sunrise_sunset_data' do
      association = described_class.reflect_on_association(:sunrise_sunset_data)
      expect(association.macro).to eq(:has_many)
      expect(association.class_name).to eq('SunriseSunsetData')
    end
  end
end
