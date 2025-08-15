# 🌅 Sunrise Sunset Explorer

A comprehensive full-stack application for exploring sunrise, sunset, and golden hour data worldwide. Built with modern technologies and designed for scalability, performance, and user experience.

## 📖 Project Overview

This project consists of two main components:
- **Backend API** (Ruby on Rails 8.0) - Robust data processing and caching
- **Frontend App** (React + TypeScript) - Modern, interactive user interface

The application provides accurate solar data for any location globally, with intelligent caching, polar region support, and beautiful visualizations.

## 🎯 Quick Start

### Prerequisites
- **Ruby 3.4.2** (for backend)
- **Node.js 18+** (for frontend)
- **PostgreSQL 12+**

### 1. Backend Setup
```bash
cd sunrise-sunset-api
bundle install
cp .env.example .env
# Configure your database credentials in .env
rails db:create db:migrate
rails server  # Runs on port 3000
```

### 2. Frontend Setup
```bash
cd sunrise-sunset-frontend
npm install
cp .env.example .env.development
# Set VITE_API_BASE_URL=http://localhost:3000/api/v1
npm run dev  # Runs on port 5173
```

### 3. Access the Application
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **Health Check**: http://localhost:3000/health

## 🏗️ Architecture

### Backend (Rails API)
- **Modern Rails 8.0** with API-only configuration
- **PostgreSQL** for reliable data persistence
- **Smart Geocoding** via Open-Meteo API
- **Solar Data** from Sunrise-Sunset.io API
- **Comprehensive Testing** with RSpec

### Frontend (React + TypeScript)
- **React 18** with modern hooks and patterns
- **TypeScript** for type safety and developer experience
- **Chart.js** for beautiful data visualizations
- **Styled Components** for component-scoped styling
- **React Hook Form** for efficient form handling
- **Vitest** for fast, modern testing

## ✨ Key Features

### 🌍 Global Coverage
- Search any city or location worldwide
- Automatic coordinate resolution via geocoding
- Support for international location names
- Recent locations for quick access

### 📊 Rich Visualizations
- Interactive timeline charts showing sunrise/sunset patterns
- Responsive data tables with sorting capabilities
- Polar region indicators (polar day/night)
- Beautiful glassmorphism UI design

### ⚡ Performance Optimized
- **Database-first caching** minimizes external API calls
- **Smart data fetching** only requests missing dates
- **Response optimization** with metadata about cache hits
- **Efficient state management** in React

### ❄️ Polar Region Support
- Graceful handling of Arctic/Antarctic regions
- Special indicators for polar day (24h daylight)
- Polar night detection (24h darkness)
- Automatic fallback for edge cases

### 🛡️ Production Ready
- **Comprehensive error handling** with user-friendly messages
- **Rate limiting** to prevent API abuse
- **Security headers** and CORS configuration
- **Health monitoring** endpoints
- **Docker support** for easy deployment

## 📱 User Experience

### Search Flow
1. **Location Input** - Type any city name with autocomplete
2. **Date Range** - Select start and end dates (minimum 2 days)
3. **Data Visualization** - View interactive charts and detailed tables
4. **Recent Locations** - Quick access to previously searched places

### Data Presentation
- **Timeline Charts** - Visual representation of sunrise/sunset patterns
- **Detailed Tables** - Comprehensive solar data with special condition indicators
- **Performance Metrics** - Cache statistics and API optimization info
- **Responsive Design** - Works beautifully on desktop, tablet, and mobile

## 🧪 Testing Strategy

### Backend Testing
```bash
cd sunrise-sunset-api
bundle exec rspec                    # Run all tests
bundle exec rspec spec/controllers   # Controller tests
bundle exec rspec spec/services      # Service tests
bundle exec brakeman                 # Security scan
bundle exec rubocop                  # Code style
```

### Frontend Testing
```bash
cd sunrise-sunset-frontend
npm run test              # Watch mode
npm run test:run          # Single run
npm run test:coverage     # With coverage
npm run test:ui           # Visual UI
```

## 🚀 Deployment

### Backend Deployment (Kamal)
```bash
cd sunrise-sunset-api
kamal setup               # Initial setup
kamal deploy              # Deploy application
```

### Frontend Deployment
```bash
cd sunrise-sunset-frontend
npm run build             # Create production build
# Deploy dist/ folder to your hosting platform
```

## 📊 API Documentation

### Main Endpoint
```http
GET /api/v1/sunrise_sunset
  ?location=Lisbon
  &start_date=2024-08-01
  &end_date=2024-08-03
```

### Response Example
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
      "day_length_formatted": "13h 15m",
      "polar_day": false,
      "polar_night": false
    }
  ],
  "meta": {
    "total_days": 3,
    "cached_records": 2,
    "generated_at": "2024-08-13T10:30:00Z"
  }
}
```

### Additional Endpoints
- `GET /api/v1/sunrise_sunset/locations` - Recent locations
- `GET /health` - System health check

## Next Identified Improvements

### 1. Add more end-to-end integration tests
- **Status**: In planing
- **Objective**: Complete user flow coverage
- **Tools**: Cypress or Playwright for E2E testing

### 2. Implement retry logic for external services
- **Status**: In planing
- **Objective**: Greater resilience against temporary failures

### 3. Add structured logging for production
- **Status**: In planing
- **Objective**: Better observability and debugging
- **Tools**: 
  - Backend: Structured logging com JSON
  - Frontend: Error boundary com reporting
- **Metrics**:
  - API response times
  - Cache hit/miss rate
  - Geocoding and external API errors

### 4. More granular cache invalidation
- **Status**: In planing
- **Objective**: Smarter and more efficient caching
- **Melhorias**:
  - TTL based on data type
  - Location-specific invalidation
  - Cache warming for popular locations
 
### 5. **Docker**
- **Status**: In planing
- **Objective**: Simplified deployment and consistent development environments across teams

## 🔧 Development Workflow

### Adding New Features
1. **Backend**: Create service → Add tests → Implement endpoint
2. **Frontend**: Create types → Build components → Add tests
3. **Integration**: End-to-end testing → Performance validation

### Code Quality Standards
- **Ruby**: RuboCop with Rails Omakase config
- **TypeScript**: ESLint with strict type checking
- **Testing**: Minimum 80% coverage requirement
- **Security**: Brakeman scans and dependency updates

## 📚 Additional Resources

### Backend Details
- [Backend README](./sunrise-sunset-api/README.md) - Detailed API documentation
- [API Architecture](./sunrise-sunset-api/README.md#architecture--design) - Service layer design
- [Database Schema](./sunrise-sunset-api/README.md#database-schema) - Data models

### Frontend Details  
- [Frontend README](./sunrise-sunset-frontend/README.md) - UI component library
- [Component Architecture](./sunrise-sunset-frontend/README.md#architecture--design) - React patterns
- [Testing Strategy](./sunrise-sunset-frontend/README.md#testing-strategy) - Frontend testing

### External APIs
- [Open-Meteo Geocoding](https://geocoding-api.open-meteo.com) - Location resolution
- [Sunrise-Sunset.io](https://api.sunrisesunset.io) - Solar calculations

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Set up backend and frontend (see Quick Start)
3. Create feature branch
4. Run tests and ensure they pass
5. Submit pull request

### Contribution Guidelines
- Follow existing code style and patterns
- Add tests for new functionality
- Update documentation as needed
- Ensure all CI checks pass

## 📄 License

This project is part of a technical challenge and is intended for demonstration purposes.

---

**Built with ❤️ using Ruby on Rails, React, and modern web technologies.**
