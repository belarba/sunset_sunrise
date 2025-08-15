require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'factory_bot_rails'
require 'webmock/rspec'
require 'vcr'

# Configuração do WebMock
WebMock.disable_net_connect!(allow_localhost: true)

# Configuração do VCR
VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false
end

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Factory Bot configuration
  config.include FactoryBot::Syntax::Methods

  # Controller routes
  config.before(:each, type: :controller) do
    @routes = Rails.application.routes
  end

  # Database Cleaner configuration
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Cache clearing
  config.before(:each) do
    Rails.cache.clear if Rails.cache.respond_to?(:clear)
  end

  # Configuração condicional de mocks - CORRIGIDO
  config.before(:each) do |example|
    # Só mocka se NÃO for um teste com VCR
    unless example.metadata[:vcr]
      allow(GeocodingService).to receive(:get_coordinates).and_return({
        latitude: 38.7223,
        longitude: -9.1393,
        name: 'Lisbon',
        country: 'Portugal',
        admin1: 'Lisboa'
      })
    end
  end

  # Tags para diferentes tipos de teste
  config.filter_run_excluding :slow unless ENV['RUN_SLOW_TESTS']
  config.filter_run_excluding :integration unless ENV['RUN_INTEGRATION_TESTS']
  config.filter_run_excluding :vcr unless ENV['RUN_VCR_TESTS']
end
