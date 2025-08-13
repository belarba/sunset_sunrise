FactoryBot.define do
  factory :sunrise_sunset_data do
    association :location
    date { Faker::Date.between(from: 1.year.ago, to: Date.current) }
    sunrise { Time.parse("#{rand(5..7)}:#{rand(10..59)}:00 UTC") }
    sunset { Time.parse("#{rand(18..20)}:#{rand(10..59)}:00 UTC") }
    solar_noon { Time.parse("12:#{rand(20..40)}:00 UTC") }
    day_length_seconds { rand(30000..60000) }
    golden_hour { Time.parse("#{rand(17..19)}:#{rand(10..59)}:00 UTC") }
    timezone { "America/New_York" }
    utc_offset { -300 }
    raw_api_data { { status: 'OK', results: {} } }

    trait :lisbon do
      association :location, :lisbon
    end

    trait :berlin do
      association :location, :berlin
    end

    trait :polar_region do
      association :location, :polar_region
      sunrise { nil }
      sunset { nil }
      golden_hour { nil }
    end

    trait :polar_day do
      polar_region
      day_length_seconds { 86400 }
    end

    trait :polar_night do
      polar_region
      day_length_seconds { 0 }
    end

    trait :recent do
      date { Date.current }
      created_at { 1.minute.ago }
    end

    trait :cached do
      created_at { 1.hour.ago }
    end

    # Para compatibilidade com testes existentes
    trait :with_coordinates do
      transient do
        latitude { nil }
        longitude { nil }
        location_name { nil }
      end

      after(:build) do |data, evaluator|
        if evaluator.latitude && evaluator.longitude
          data.location = build(:location,
            latitude: evaluator.latitude,
            longitude: evaluator.longitude,
            display_name: evaluator.location_name || "Test Location"
          )
        end
      end
    end
  end
end
