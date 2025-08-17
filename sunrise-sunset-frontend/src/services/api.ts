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
      console.log(`📍 Full URL: ${config.baseURL}${config.url}`);
      if (config.params) {
        console.log(`📋 Params:`, config.params);
      }
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
      console.log(`📦 Response data:`, response.data);
    }
    return response;
  },
  (error) => {
    if (env.enableApiLogging) {
      console.error('❌ Response Error:', error);
      if (error.response) {
        console.error('📦 Error response data:', error.response.data);
        console.error('📊 Error status:', error.response.status);
      }
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
      
      // Se a resposta tem status "error", não é um erro de rede, mas um erro de aplicação
      if (response.data.status === 'error') {
        return response.data;
      }
      
      return response.data;
    } catch (error) {
      console.error('🔴 API Error in getSunriseSunsetData:', error);
      
      if (axios.isAxiosError(error)) {
        if (error.response) {
          // O servidor respondeu com um status de erro
          console.error(`📊 Response status: ${error.response.status}`);
          console.error(`📦 Response data:`, error.response.data);
          
          // Se o backend retornou um JSON com erro estruturado, usar esse erro
          if (error.response.data && typeof error.response.data === 'object') {
            return error.response.data;
          }
          
          // Fallback para erro HTTP genérico
          return {
            status: 'error',
            error: 'http_error',
            message: `Server error: ${error.response.status} ${error.response.statusText}`,
            timestamp: new Date().toISOString()
          };
        } else if (error.request) {
          // A requisição foi feita mas não houve resposta
          console.error('📡 No response received:', error.request);
          return {
            status: 'error',
            error: 'network_error',
            message: `No response from server. Please check if the backend is running on ${env.apiBaseUrl}`,
            timestamp: new Date().toISOString()
          };
        } else {
          // Algo aconteceu na configuração da requisição
          console.error('⚙️ Request setup error:', error.message);
          return {
            status: 'error',
            error: 'request_error',
            message: `Request configuration error: ${error.message}`,
            timestamp: new Date().toISOString()
          };
        }
      }
      
      // Erro não relacionado ao Axios
      console.error('❓ Unknown error:', error);
      return {
        status: 'error',
        error: 'unknown_error',
        message: error instanceof Error ? error.message : 'An unknown error occurred',
        timestamp: new Date().toISOString()
      };
    }
  },

  async getRecentLocations(): Promise<string[]> {
    try {
      const response = await api.get('/sunrise_sunset/locations');
      
      if (env.enableApiLogging) {
        console.log('📍 Recent locations response:', response.data);
      }
      
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