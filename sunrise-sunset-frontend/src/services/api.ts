import axios from 'axios';
import type { ApiResponse } from '../types';

const api = axios.create({
  baseURL: 'http://localhost:3000/api/v1',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for logging
api.interceptors.request.use(
  (config) => {
    console.log(`🚀 API Request: ${config.method?.toUpperCase()} ${config.url}`);
    return config;
  },
  (error) => {
    console.error('❌ Request Error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor for logging
api.interceptors.response.use(
  (response) => {
    console.log(`✅ API Response: ${response.status} ${response.config.url}`);
    return response;
  },
  (error) => {
    console.error('❌ Response Error:', error);
    return Promise.reject(error);
  }
);

export const sunriseSunsetService = {
  async getSunriseSunsetData(
    location: string,
    startDate: string,
    endDate: string
  ): Promise<ApiResponse> {
    try {
      const response = await api.get('/sunrise_sunset', {
        params: {
          location,
          start_date: startDate,
          end_date: endDate,
        },
      });
      return response.data;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        if (error.response) {
          // Server responded with error status
          return error.response.data;
        } else if (error.request) {
          // Request was made but no response received
          throw new Error('No response from server. Please check if the backend is running on port 3000.');
        }
      }
      // Something else happened
      throw new Error('Network error occurred');
    }
  },

  async getRecentLocations(): Promise<string[]> {
    try {
      const response = await api.get('/sunrise_sunset/locations');
      return response.data.locations || [];
    } catch (error) {
      console.error('Failed to fetch recent locations:', error);
      return [];
    }
  },

  async getHealthStatus() {
    try {
      const response = await api.get('/health');
      return response.data;
    } catch (error) {
      console.error('Health check failed:', error);
      return { status: 'unhealthy' };
    }
  },
};