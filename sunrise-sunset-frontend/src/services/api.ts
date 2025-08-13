import axios from 'axios';
import { env } from '../config/env';
import type { ApiResponse } from '../types';

const api = axios.create({
  baseURL: env.apiBaseUrl,
  timeout: env.apiTimeout,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor para logging (apenas em desenvolvimento)
api.interceptors.request.use(
  (config) => {
    if (env.enableApiLogging) {
      console.log(`🚀 API Request: ${config.method?.toUpperCase()} ${config.url}`);
    }
    return config;
  },
  (error) => {
    if (env.enableApiLogging) {
      console.error('❌ Request Error:', error);
    }
    return Promise.reject(error);
  }
);

// Response interceptor para logging
api.interceptors.response.use(
  (response) => {
    if (env.enableApiLogging) {
      console.log(`✅ API Response: ${response.status} ${response.config.url}`);
    }
    return response;
  },
  (error) => {
    if (env.enableApiLogging) {
      console.error('❌ Response Error:', error);
    }
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
          return error.response.data;
        } else if (error.request) {
          throw new Error(
            `No response from server. Please check if the backend is running on ${env.apiBaseUrl}`
          );
        }
      }
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