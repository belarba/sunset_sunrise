# Sunrise Sunset Frontend 🌅⚛️

A modern React TypeScript frontend application for exploring sunrise, sunset, and golden hour data worldwide. Built with cutting-edge tools and beautiful visualizations, this application provides an intuitive interface for discovering solar data with interactive charts and detailed tables.

## 🚀 Features

- **🌍 Global Location Search**: Intelligent location search with autocomplete and recent locations
- **📊 Interactive Charts**: Beautiful timeline visualizations using Chart.js
- **📋 Detailed Data Tables**: Comprehensive solar data with smart formatting
- **❄️ Polar Region Support**: Graceful handling of Arctic/Antarctic regions
- **💾 Smart Caching**: Optimized API calls with backend caching integration
- **📱 Responsive Design**: Mobile-first responsive interface
- **🎨 Modern UI/UX**: Glass morphism design with smooth animations
- **⚡ Performance Optimized**: Fast loading with intelligent state management
- **🧪 Comprehensive Testing**: Full test coverage with Vitest and Testing Library

## 🛠️ Technology Stack

### Frontend Framework
- **React 18.3.1** - Modern React with concurrent features
- **TypeScript 5.9.2** - Type-safe development experience
- **Vite 5.4.19** - Lightning-fast build tool and dev server

### Styling & UI
- **Styled Components 6.1.19** - CSS-in-JS with theming support
- **CSS-in-JS Architecture** - Component-scoped styling
- **Custom Design System** - Consistent UI components and theme
- **Responsive Grid Layout** - Mobile-first responsive design
- **Glass Morphism Effects** - Modern UI aesthetics with backdrop filters

### Data Visualization
- **Chart.js 4.5.0** - Powerful charting library
- **React-ChartJS-2 5.3.0** - React wrapper for Chart.js
- **Interactive Timelines** - Beautiful sunrise/sunset visualizations
- **Custom Chart Themes** - Branded color schemes and styling

### Form Management
- **React Hook Form 7.62.0** - Performant form handling
- **Yup 1.7.0** - Schema validation
- **@hookform/resolvers 3.10.0** - Validation integration
- **Smart Validation** - Real-time form validation with helpful messages

### State Management & API
- **Axios 1.11.0** - HTTP client with interceptors
- **React Hot Toast 2.5.2** - Beautiful notification system
- **Date-fns 3.6.0** - Modern date manipulation
- **Custom Hook Patterns** - Reusable state logic

### Development & Testing
- **Vitest 1.6.1** - Fast unit test runner
- **@testing-library/react 14.3.1** - Component testing utilities
- **@testing-library/user-event 14.6.1** - User interaction testing
- **@testing-library/jest-dom 6.6.4** - DOM testing matchers
- **JSDOM 23.2.0** - DOM environment for testing

### Code Quality & Tooling
- **ESLint 8.57.1** - Linting with React-specific rules
- **TypeScript Strict Mode** - Maximum type safety
- **Vite Plugins** - Optimized development experience
- **Hot Module Replacement** - Instant development feedback

## 📋 Application Features

### 🔍 Location Search
- **Intelligent Autocomplete**: Search for any city or location worldwide
- **Recent Locations**: Quick access to previously searched locations
- **Geocoding Integration**: Automatic coordinate resolution
- **Error Handling**: Helpful messages for invalid locations

### 📊 Data Visualization
- **Interactive Timeline Charts**: Beautiful Chart.js visualizations
- **Multiple Data Series**: Sunrise, sunset, and golden hour times
- **Responsive Design**: Charts adapt to screen sizes
- **Custom Tooltips**: Detailed hover information
- **Time Format Handling**: Automatic time formatting and display

### 📋 Data Tables
- **Sortable Columns**: Interactive data sorting
- **Responsive Layout**: Mobile-friendly table design
- **Special Conditions**: Polar day/night indicators
- **Performance Metrics**: Cache statistics and API call optimization
- **Export Ready**: Clean data presentation

### 🌐 API Integration
- **RESTful API Client**: Clean Axios-based service layer
- **Error Handling**: Comprehensive error management
- **Loading States**: Smooth loading experiences
- **Retry Logic**: Automatic retry for failed requests
- **Response Caching**: Optimized data fetching

## 🚀 Getting Started

### Prerequisites
- **Node.js 18+** (LTS recommended)
- **npm 8+** or **yarn 1.22+**
- **Running Backend API** (sunrise-sunset-api on port 3000)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd sunrise-sunset-frontend
```

2. **Install dependencies**
```bash
npm install
# or
yarn install
```

3. **Environment Setup**
The application expects the backend API to be running on `http://localhost:3000`. No additional environment configuration is required for development.

4. **Start development server**
```bash
npm run dev
# or
yarn dev
```

The application will be available at `http://localhost:5173`

## 🧪 Testing

### Run all tests
```bash
npm run test
# or
yarn test
```

### Run tests with UI
```bash
npm run test:ui
# or
yarn test:ui
```

### Run tests once (CI mode)
```bash
npm run test:run
# or
yarn test:run
```

### Generate test coverage
```bash
npm run test:coverage
# or
yarn test:coverage
```

### Test Structure
```
src/
├── _tests__/           # Application-level tests
├── components/
│   ├── forms/
│   │   └── _tests__/   # Form component tests
│   └── ui/
│       └── __tests__/  # UI component tests
├── services/
│   └── __tests__/      # API service tests
└── test/
    ├── setup.ts        # Test configuration
    └── test-utils.ts   # Testing utilities
```

## 🏗️ Architecture & Design

### Component Structure
```
src/
├── components/
│   ├── charts/         # Data visualization components
│   ├── forms/          # Form components
│   └── ui/             # Reusable UI components
├── services/           # API integration layer
├── styles/             # Global styles and theme
├── types/              # TypeScript type definitions
└── test/               # Testing configuration
```

### Design System
- **Card Components** - Glassmorphism-styled containers
- **Button System** - Multiple variants with loading states
- **Input Components** - Consistent form styling
- **Typography Scale** - Hierarchical text styling
- **Color Palette** - Branded color system
- **Spacing System** - Consistent spacing tokens

### State Management
- **Local Component State** - React useState for UI state
- **Form State** - React Hook Form for complex forms
- **API State** - Custom hooks for data fetching
- **Global State** - Context API for shared state (if needed)

### Performance Optimizations
- **Component Memoization** - React.memo for expensive components
- **Code Splitting** - Dynamic imports for route-based splitting
- **Image Optimization** - Optimized asset loading
- **Bundle Analysis** - Vite bundle analyzer integration

## 🎨 UI/UX Features

### Visual Design
- **Glass Morphism** - Modern frosted glass effects
- **Gradient Backgrounds** - Beautiful gradient compositions
- **Smooth Animations** - CSS transitions and keyframes
- **Micro Interactions** - Hover states and focus indicators
- **Dark/Light Adaptable** - Prepared for theme switching

### User Experience
- **Loading States** - Clear loading indicators
- **Error Boundaries** - Graceful error handling
- **Empty States** - Helpful empty state illustrations
- **Progressive Enhancement** - Works without JavaScript
- **Accessibility** - WCAG compliance considerations

### Responsive Design
```css
/* Mobile First Approach */
@media (min-width: 640px)  { /* sm */ }
@media (min-width: 768px)  { /* md */ }
@media (min-width: 1024px) { /* lg */ }
@media (min-width: 1280px) { /* xl */ }
```

## 📊 Data Flow

### API Integration Flow
1. **User Input** → Form validation with Yup
2. **API Request** → Axios service with interceptors
3. **Data Processing** → Type-safe data transformation
4. **State Update** → React state management
5. **UI Rendering** → Component re-rendering
6. **User Feedback** → Toast notifications and loading states

### Chart Data Pipeline
1. **Raw API Data** → SunriseSunsetData[]
2. **Data Transformation** → Chart.js compatible format
3. **Chart Configuration** → Custom options and styling
4. **Responsive Rendering** → Adaptive chart sizing
5. **Interactive Features** → Tooltips and hover states

## 🔧 Development Scripts

```bash
# Development server with HMR
npm run dev

# Type checking
npm run type-check

# Build for production
npm run build

# Preview production build
npm run preview

# Linting
npm run lint

# Testing (various modes)
npm run test        # Watch mode
npm run test:ui     # UI mode
npm run test:run    # Single run
npm run test:coverage # With coverage
```

## 📱 Browser Support

- **Chrome** 88+ ✅
- **Firefox** 85+ ✅  
- **Safari** 14+ ✅
- **Edge** 88+ ✅
- **Mobile Safari** iOS 14+ ✅
- **Chrome Mobile** Android 88+ ✅

## 🚀 Production Build

### Build Optimization
```bash
# Create production build
npm run build

# Analyze bundle size
npm run build && npx vite-bundle-analyzer dist
```

### Build Output
```
dist/
├── assets/
│   ├── index-[hash].js    # Main application bundle
│   ├── index-[hash].css   # Compiled styles
│   └── [vendor]-[hash].js # Vendor libraries
├── index.html             # HTML entry point
└── vite.svg              # Favicon
```

### Deployment Ready
- **Static Hosting** - Compatible with Netlify, Vercel, GitHub Pages
- **CDN Optimized** - Asset hashing and caching headers
- **Gzip Compression** - Optimized bundle sizes
- **Modern ES Modules** - Optimized for modern browsers

## 🌐 API Integration

### Service Layer
```typescript
// Clean API service abstraction
export const sunriseSunsetService = {
  async getSunriseSunsetData(location, startDate, endDate): Promise<ApiResponse>
  async getRecentLocations(): Promise<string[]>
  async getHealthStatus(): Promise<HealthResponse>
}
```

### Error Handling
- **Network Errors** - Connection failure handling
- **API Errors** - Backend error message display
- **Validation Errors** - Form validation feedback
- **Timeout Handling** - Request timeout management

### Type Safety
```typescript
// Complete type definitions
interface SunriseSunsetData {
  id: number
  location: string
  latitude: number
  longitude: number
  date: string
  sunrise: string | null
  sunset: string | null
  // ... comprehensive type coverage
}
```

## 🧪 Testing Strategy

### Test Coverage
- **Unit Tests** - Component logic and utilities
- **Integration Tests** - Component interaction
- **API Tests** - Service layer functionality
- **User Journey Tests** - Complete user workflows

### Testing Philosophy
- **User-Centric** - Testing from user perspective
- **Accessibility** - Screen reader and keyboard testing
- **Error Scenarios** - Testing edge cases and failures
- **Performance** - Testing rendering performance

### Mock Strategy
```typescript
// Comprehensive mocking
vi.mock('../services/api', () => ({
  sunriseSunsetService: {
    getSunriseSunsetData: vi.fn(),
    getRecentLocations: vi.fn(),
  },
}))
```

## 🔐 Security Considerations

- **Input Sanitization** - All user inputs validated
- **XSS Prevention** - React's built-in protections
- **API Security** - Secure HTTP client configuration
- **Environment Variables** - No sensitive data in frontend
- **CSP Ready** - Content Security Policy compatible

## 🚀 Performance Metrics

### Core Web Vitals Targets
- **First Contentful Paint** < 1.5s
- **Largest Contentful Paint** < 2.5s
- **Cumulative Layout Shift** < 0.1
- **First Input Delay** < 100ms

### Bundle Size Optimization
- **Main Bundle** ~150KB gzipped
- **Vendor Bundle** ~300KB gzipped (React, Chart.js)
- **CSS Bundle** ~20KB gzipped
- **Total Initial Load** ~470KB gzipped

## 🤝 Contributing

### Development Workflow
1. **Fork** the repository
2. **Create** feature branch (`git checkout -b feature/amazing-feature`)
3. **Install** dependencies (`npm install`)
4. **Start** dev server (`npm run dev`)
5. **Write** tests for new features
6. **Run** test suite (`npm run test`)
7. **Check** types (`npm run type-check`)
8. **Lint** code (`npm run lint`)
9. **Commit** changes (`git commit -m 'Add amazing feature'`)
10. **Push** to branch (`git push origin feature/amazing-feature`)
11. **Open** Pull Request

### Code Standards
- **TypeScript Strict** - Maximum type safety
- **ESLint Rules** - React and accessibility best practices
- **Component Patterns** - Consistent component structure
- **Test Coverage** - Minimum 80% coverage requirement
- **Documentation** - JSDoc for complex functions

### Pull Request Checklist
- [ ] Tests pass (`npm run test`)
- [ ] Types check (`npm run type-check`)
- [ ] Linting passes (`npm run lint`)
- [ ] Build succeeds (`npm run build`)
- [ ] Manual testing completed
- [ ] Responsive design verified
- [ ] Accessibility tested

## 📄 License

This project is part of the Jumpseller Technical Challenge.

---

Built with ❤️ using React, TypeScript, and modern web technolog
