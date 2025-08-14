# Sunrise Sunset API 🌅🌇

A comprehensive Ruby on Rails API for retrieving and storing historical sunrise, sunset, and golden hour data for any location worldwide. The application intelligently caches data to minimize external API calls and provides robust error handling for edge cases including polar regions.

## 🚀 Features

- **Location-based Solar Data**: Get sunrise, sunset, and golden hour times for any city or location
- **Date Range Queries**: Retrieve data for single days or extended date ranges (up to 365 days)
- **Smart Caching**: Database-first approach minimizes external API calls
- **Polar Region Support**: Graceful handling of Arctic/Antarctic regions where sun doesn't rise/set
- **Geocoding Integration**: Automatic coordinate resolution from location names
- **Rate Limiting**: Built-in API rate limiting for production use
- **Comprehensive Error Handling**: Robust error responses for all edge cases
- **Health Monitoring**: Built-in health check and monitoring endpoints

## 🛠️ Technology Stack

### Backend Framework
- **Ruby 3.4.2** - Latest stable Ruby version
- **Rails 8.0.2** - Modern Rails API-only application
- **PostgreSQL** - Primary database for data persistence
- **Memory Cache** - In-memory caching for performance optimization

### External API Integrations
- **🌍 Open-Meteo Geocoding API** (`https://geocoding-api.open-meteo.com/v1`)
  - Converts location names to precise coordinates
  - Provides detailed location metadata (country, region)
  - Supports international location names
  - Free tier with generous limits

- **☀️ Sunrise-Sunset.io API** (`https://api.sunrisesunset.io`)
  - Retrieves precise solar data for any coordinates
  - Provides sunrise, sunset, solar noon, and day length
  - Handles timezone calculations automatically
  - Special handling for polar regions

### Key Gems & Libraries
- **HTTParty** - HTTP client for external API communications
- **Rack-CORS** - Cross-origin resource sharing for frontend integration
- **JBuilder** - Clean JSON API responses
- **Dotenv** - Environment variable management
- **Active Model Serializers** - API response serialization

### Development & Testing
- **RSpec** - Comprehensive testing framework
- **Factory Bot** - Test data generation
- **WebMock/VCR** - HTTP request mocking and recording
- **Database Cleaner** - Test database management
- **Brakeman** - Security vulnerability scanning
- **RuboCop** - Code style and quality enforcement

### Production & Deployment
- **Docker** - Containerization for consistent deployments
- **Kamal** - Modern Rails deployment tool
- **Thruster** - High-performance Ruby web server
- **Solid Queue** - Background job processing
- **Solid Cache** - Database-backed caching

## 📋 API Endpoints

### Get Sunrise/Sunset Data
```http
GET /api/v1/sunrise_sunset
```

**Parameters:**
- `location` (required) - City name or location (e.g., "Lisbon", "Berlin", "New York")
- `start_date` (required) - Start date in YYYY-MM-DD format
- `end_date` (required) - End date in YYYY-MM-DD format

**Example Request:**
```bash
curl "http://localhost:3000/api/v1/sunrise_sunset?location=Lisbon&start_date=2024-08-01&end_date=2024-08-03"
```

**Example Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "location": "Lisbon, Portugal",
      "latitude": 38.7223,
      "longitude": -9.1393,
      "date": "2024-08-01",
      "sunrise": "06:30:15",
      "sunset": "19:45:22",
      "solar_noon": "13:07:48",
      "day_length_seconds": 47707,
      "day_length_formatted": "13h 15m",
      "golden_hour": "18:45:22",
      "timezone": "Europe/Lisbon",
      "utc_offset": 3600,
      "polar_day": false,
      "polar_night": false,
      "created_at": "2024-08-13T10:30:00Z",
      "updated_at": "2024-08-13T10:30:00Z"
    }
  ],
  "meta": {
    "location": "Lisbon",
    "start_date": "2024-08-01",
    "end_date": "2024-08-03",
    "total_days": 3,
    "cached_records": 1,
    "generated_at": "2024-08-13T10:30:00Z"
  }
}
```

### Get Recent Locations
```http
GET /api/v1/sunrise_sunset/locations
```

Returns a list of recently queried locations for quick access.

### Health Check
```http
GET /health
```

Returns API health status and system information.

## 🔧 Installation & Setup

### Prerequisites
- Ruby 3.4.2
- PostgreSQL 12+
- Git

### Local Development Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd sunrise-sunset-api
```

2. **Install dependencies**
```bash
bundle install
```

3. **Environment configuration**
```bash
cp .env.example .env
```

Edit the `.env` file with your database credentials:
```env
DATABASE_HOST=localhost
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_password_here
DATABASE_NAME_DEVELOPMENT=sunrise_sunset_development
DATABASE_NAME_TEST=sunrise_sunset_test
DATABASE_PORT=5432

# API Configuration
SUNRISE_SUNSET_API_URL=https://api.sunrisesunset.io
GEOCODING_API_URL=https://geocoding-api.open-meteo.com/v1
API_TIMEOUT=15
CACHE_EXPIRES_IN=604800
```

4. **Database setup**
```bash
rails db:create
rails db:migrate
```

5. **Start the server**
```bash
rails server
```

The API will be available at `http://localhost:3000`

## 🧪 Testing

### Run the complete test suite
```bash
bundle exec rspec
```

### Run specific test types
```bash
# Controller tests
bundle exec rspec spec/controllers

# Model tests  
bundle exec rspec spec/models

# Service tests
bundle exec rspec spec/services

# Request tests
bundle exec rspec spec/requests
```

### Security scanning
```bash
bundle exec brakeman
```

### Code style checking
```bash
bundle exec rubocop
```

## 🏗️ Architecture & Design

### Database Schema
- **locations** - Stores geocoded location data with coordinates
- **sunrise_sunset_data** - Historical solar data linked to locations
- Optimized indexes for fast location and date-based queries

### Service Layer
- **SunriseSunsetService** - Orchestrates data fetching with intelligent caching
- **GeocodingService** - Handles location name to coordinate conversion
- **RateLimiter** - Middleware for API rate limiting

### Caching Strategy
1. **Database First** - Check for existing data before API calls
3. **Location Cache** - Recent locations list (1 hour)
4. **Configurable TTL** - Environment-based cache expiration

### Error Handling
- **Invalid Locations** - Graceful handling with helpful error messages
- **Polar Regions** - Special logic for Arctic/Antarctic locations
- **API Failures** - Fallback mechanisms and retry logic
- **Rate Limiting** - 429 responses with proper headers

## 🚀 Production Deployment

### Using Kamal (Recommended)
```bash
# Setup deployment configuration
kamal setup

# Deploy
kamal deploy
```

### Manual Docker Deployment
```bash
# Build production image
docker build -t sunrise-sunset-api .

# Run with production environment
docker run -d \
  -p 80:80 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  -e DATABASE_URL=postgresql://... \
  sunrise-sunset-api
```

## 📊 Performance & Monitoring

### Caching Metrics
- **Cache Hit Ratio** - Monitor via `/health` endpoint
- **API Call Reduction** - Tracked in response metadata
- **Response Times** - Built-in Rails instrumentation

### Rate Limiting
- **Default Limit** - 100 requests per hour per IP
- **Configurable** - Via `RATE_LIMIT_REQUESTS_PER_HOUR` environment variable
- **Response Headers** - Standard rate limit headers included

## 🌍 External API Details

### Open-Meteo Geocoding API
- **Purpose**: Convert location names to precise coordinates
- **Rate Limits**: Generous free tier (10,000 requests/day)
- **Data Quality**: High-quality global location database
- **Caching**: 7-day cache to minimize repeated calls
- **Error Handling**: Graceful fallback for ambiguous locations

### Sunrise-Sunset.io API  
- **Purpose**: Retrieve precise solar calculation data
- **Coverage**: Global coverage with high accuracy
- **Special Features**: Automatic polar region detection
- **Data Points**: Sunrise, sunset, solar noon, twilight times, day length
- **Timezone Handling**: Automatic timezone conversion

## 📝 API Response Examples

### Successful Response
```json
{
  "status": "success",
  "data": [...],
  "meta": {
    "cached_records": 2,
    "total_days": 3,
    "generated_at": "2024-08-13T10:30:00Z"
  }
}
```

### Error Responses
```json
{
  "status": "error",
  "error": "invalid_location",
  "message": "Location 'InvalidPlace' not found",
  "timestamp": "2024-08-13T10:30:00Z"
}
```

### Polar Region Response
```json
{
  "data": [{
    "sunrise": null,
    "sunset": null,
    "polar_day": true,
    "polar_night": false,
    "day_length_seconds": 86400
  }]
}
```

## 🔐 Security Features

- **Parameter Validation** - Strict input validation and sanitization
- **Rate Limiting** - Per-IP request limiting
- **CORS Configuration** - Controlled cross-origin access
- **SQL Injection Prevention** - Parameterized queries via ActiveRecord
- **Security Headers** - Standard Rails security headers
- **Credential Management** - Encrypted credentials system

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`bundle exec rspec`)
4. Commit changes (`git commit -m 'Add amazing feature'`)
5. Push to branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

