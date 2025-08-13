FactoryBot.define do
  factory :location do
    name { Faker::Address.city }
    search_name { name.downcase.strip }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    country { Faker::Address.country }
    admin1 { Faker::Address.state }
    display_name { "#{name}, #{country}" }
    raw_geocoding_data { { name: name, country: country, admin1: admin1 } }

    trait :lisbon do
      name { 'Lisbon' }
      search_name { 'lisbon' }
      latitude { 38.7223 }
      longitude { -9.1393 }
      country { 'Portugal' }
      admin1 { 'Lisboa' }
      display_name { 'Lisbon, Portugal' }
    end

    trait :berlin do
      name { 'Berlin' }
      search_name { 'berlin' }
      latitude { 52.5200 }
      longitude { 13.4050 }
      country { 'Germany' }
      admin1 { 'Berlin' }
      display_name { 'Berlin, Germany' }
    end

    trait :polar_region do
      name { 'Svalbard' }
      search_name { 'svalbard' }
      latitude { 78.9167 }
      longitude { 11.9500 }
      country { 'Norway' }
      admin1 { 'Svalbard' }
      display_name { 'Svalbard, Norway' }
    end
  end
end
