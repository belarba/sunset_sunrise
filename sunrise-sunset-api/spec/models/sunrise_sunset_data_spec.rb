require 'rails_helper'

RSpec.describe SunriseSunsetData, type: :model do
  let(:valid_attributes) do
    {
      location: 'Lisbon, Portugal',
      latitude: 38.7223,
      longitude: -9.1393,
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
      expect(subject.errors[:location]).to include("can't be blank")
    end

    it 'requires latitude' do
      subject.latitude = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:latitude]).to include("can't be blank")
    end

    it 'requires longitude' do
      subject.longitude = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:longitude]).to include("can't be blank")
    end

    it 'requires date' do
      subject.date = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:date]).to include("can't be blank")
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

    it 'validates uniqueness of location and date combination' do
      subject.save!

      duplicate = described_class.new(valid_attributes)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:latitude]).to include('has already been taken')
    end
  end

  describe 'scopes' do
    before do
      @lisbon_data = create(:sunrise_sunset_data,
        latitude: 38.7223, longitude: -9.1393, date: Date.today)
      @berlin_data = create(:sunrise_sunset_data,
        latitude: 52.5200, longitude: 13.4050, date: Date.today)
      @old_data = create(:sunrise_sunset_data,
        latitude: 38.7223, longitude: -9.1393, date: 1.week.ago)
    end

    describe '.by_location' do
      it 'filters by latitude and longitude' do
        results = described_class.by_location(38.7223, -9.1393)
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
      it 'returns true for polar day conditions' do
        subject.sunrise = nil
        subject.sunset = nil
        subject.day_length_seconds = 86400
        expect(subject.polar_day?).to be true
      end

      it 'returns false for normal day conditions' do
        expect(subject.polar_day?).to be false
      end
    end

    describe '#polar_night?' do
      it 'returns true for polar night conditions' do
        subject.sunrise = nil
        subject.sunset = nil
        subject.day_length_seconds = 0
        expect(subject.polar_night?).to be true
      end

      it 'returns false for normal day conditions' do
        expect(subject.polar_night?).to be false
      end
    end
  end

  describe '.find_or_fetch_data' do
    it 'returns existing data when found' do
      existing = create(:sunrise_sunset_data, valid_attributes)
      result = described_class.find_or_fetch_data(
        existing.latitude, existing.longitude, existing.location, existing.date
      )
      expect(result).to eq(existing)
    end

    it 'returns nil when data not found' do
      result = described_class.find_or_fetch_data(
        38.7223, -9.1393, 'Lisbon', Date.today
      )
      expect(result).to be_nil
    end
  end

  describe '#as_json' do
    it 'includes computed methods and excludes raw_api_data' do
      json = subject.as_json
      expect(json).to have_key('day_length_formatted')
      expect(json).to have_key('polar_day?')
      expect(json).to have_key('polar_night?')
      expect(json).not_to have_key('raw_api_data')
    end
  end
end
