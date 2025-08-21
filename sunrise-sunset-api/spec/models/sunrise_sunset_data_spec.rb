require 'rails_helper'

RSpec.describe SunriseSunsetData, type: :model do
  let(:location) { create(:location, :lisbon) }
  let(:valid_attributes) do
    {
      location: location,
      date: Date.today,
      sunrise: Time.parse('06:30:00 UTC'),
      sunset: Time.parse('19:45:00 UTC'),
      day_length_seconds: 47700
    }
  end

  subject { described_class.new(valid_attributes) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires location' do
      subject.location = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:location]).to include("must exist")
    end

    it 'requires date' do
      subject.date = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:date]).to include("can't be blank")
    end

    it 'validates uniqueness of location and date combination' do
      subject.save!

      duplicate = described_class.new(valid_attributes)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:location_id]).to include('has already been taken')
    end
  end

  describe 'scopes' do
    before do
      @lisbon_location = create(:location, :lisbon)
      @berlin_location = create(:location, :berlin)

      @lisbon_data = create(:sunrise_sunset_data, location: @lisbon_location, date: Date.today)
      @berlin_data = create(:sunrise_sunset_data, location: @berlin_location, date: Date.today)
      @old_data = create(:sunrise_sunset_data, location: @lisbon_location, date: 1.week.ago)
    end

    describe '.by_location' do
      it 'filters by location' do
        results = described_class.by_location(@lisbon_location)
        expect(results).to include(@lisbon_data, @old_data)
        expect(results).not_to include(@berlin_data)
      end
    end

    describe '.by_date_range' do
      it 'filters by date range' do
        results = described_class.by_date_range(Date.today, Date.today)
        expect(results).to include(@lisbon_data, @berlin_data)
        expect(results).not_to include(@old_data)
      end
    end

    describe '.recent' do
      it 'orders by date descending' do
        results = described_class.recent
        expect(results.first.date).to be >= results.last.date
      end
    end
  end

  describe 'instance methods' do
    subject do
      create(:sunrise_sunset_data,
        golden_hour: Time.parse('18:45:00 UTC'),
        day_length_seconds: 47700
      )
    end

    describe '#day_length_formatted' do
      it 'formats day length as hours and minutes' do
        expect(subject.day_length_formatted).to eq('13h 15m')
      end

      it 'returns nil when day_length_seconds is nil' do
        subject.day_length_seconds = nil
        expect(subject.day_length_formatted).to be_nil
      end
    end

    describe '#polar_day?' do
      context 'with polar day conditions' do
        let(:arctic_location) { create(:location, :polar_region) }

        it 'returns true for 24-hour daylight in summer' do
          data = create(:sunrise_sunset_data,
            location: arctic_location,
            date: Date.new(2024, 6, 15), # Junho - verão ártico
            sunrise: nil,
            sunset: nil,
            day_length_seconds: 86400
          )
          expect(data.polar_day?).to be true
        end

        it 'returns false for 24-hour daylight in wrong season' do
          data = create(:sunrise_sunset_data,
            location: arctic_location,
            date: Date.new(2024, 12, 15), # Dezembro - inverno ártico
            sunrise: nil,
            sunset: nil,
            day_length_seconds: 86400
          )
          expect(data.polar_day?).to be false
        end

        it 'returns false when not in polar region' do
          normal_location = create(:location, latitude: 45.0) # Não polar
          data = create(:sunrise_sunset_data,
            location: normal_location,
            sunrise: nil,
            sunset: nil,
            day_length_seconds: 86400
          )
          expect(data.polar_day?).to be false
        end
      end
    end

    describe '#polar_night?' do
      context 'with polar night conditions' do
        let(:arctic_location) { create(:location, :polar_region) }

        it 'returns true for 0-hour daylight in winter' do
          data = create(:sunrise_sunset_data,
            location: arctic_location,
            date: Date.new(2024, 12, 15), # Dezembro - inverno ártico
            sunrise: nil,
            sunset: nil,
            day_length_seconds: 0
          )
          expect(data.polar_night?).to be true
        end

        it 'returns false for 0-hour daylight in wrong season' do
          data = create(:sunrise_sunset_data,
            location: arctic_location,
            date: Date.new(2024, 6, 15), # Junho - verão ártico
            sunrise: nil,
            sunset: nil,
            day_length_seconds: 0
          )
          expect(data.polar_night?).to be false
        end

        it 'returns false when not in polar region' do
          normal_location = create(:location, latitude: 45.0) # Não polar
          data = create(:sunrise_sunset_data,
            location: normal_location,
            sunrise: nil,
            sunset: nil,
            day_length_seconds: 0
          )
          expect(data.polar_night?).to be false
        end
      end
    end

    describe '#latitude and #longitude delegation' do
      it 'delegates to location' do
        expect(subject.latitude).to eq(subject.location.latitude)
        expect(subject.longitude).to eq(subject.location.longitude)
      end
    end
  end

  describe '.find_or_fetch_data' do
    it 'returns existing data when found' do
      existing = create(:sunrise_sunset_data, valid_attributes)
      result = described_class.find_or_fetch_data(existing.location, existing.date)
      expect(result).to eq(existing)
    end

    it 'returns nil when data not found' do
      result = described_class.find_or_fetch_data(location, Date.today)
      expect(result).to be_nil
    end
  end

  describe '#as_json' do
    it 'includes computed methods and excludes raw_api_data' do
      json = subject.as_json
      expect(json).to have_key('day_length_formatted')
      expect(json).to have_key('polar_day?')
      expect(json).to have_key('polar_night?')
      expect(json).to have_key('latitude')
      expect(json).to have_key('longitude')
      expect(json).to have_key('location_name')
      expect(json).not_to have_key('raw_api_data')
    end
  end
end
