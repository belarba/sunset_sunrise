import { describe, it, expect, beforeEach, vi, type Mock } from 'vitest';
import type { ApiResponse } from '../../types';

// Mock completo do axios antes de importar qualquer coisa
const mockAxiosInstance = {
  get: vi.fn(),
  post: vi.fn(),
  put: vi.fn(),
  patch: vi.fn(),
  delete: vi.fn(),
  head: vi.fn(),
  options: vi.fn(),
  request: vi.fn(),
  getUri: vi.fn(),
  defaults: {},
  interceptors: {
    request: {
      use: vi.fn(),
      eject: vi.fn(),
      clear: vi.fn(),
    },
    response: {
      use: vi.fn(),
      eject: vi.fn(),
      clear: vi.fn(),
    },
  },
};

const mockAxios = {
  create: vi.fn(() => mockAxiosInstance),
  isAxiosError: vi.fn(),
  get: vi.fn(),
  post: vi.fn(),
  put: vi.fn(),
  patch: vi.fn(),
  delete: vi.fn(),
  head: vi.fn(),
  options: vi.fn(),
  request: vi.fn(),
};

vi.mock('axios', () => ({
  default: mockAxios,
}));

// Agora importar o serviço após o mock
const { sunriseSunsetService } = await import('../api');

describe('sunriseSunsetService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('getSunriseSunsetData', () => {
    it('should return successful response with data', async () => {
      const mockResponse: ApiResponse = {
        status: 'success',
        data: [
          {
            id: 1,
            location: 'Lisbon, Portugal',
            latitude: 38.7223,
            longitude: -9.1393,
            date: '2024-08-01',
            sunrise: '06:30:15',
            sunset: '19:45:22',
            solar_noon: '13:07:48',
            day_length_seconds: 47707,
            day_length_formatted: '13h 15m',
            golden_hour: '18:45:22',
            timezone: 'Europe/Lisbon',
            utc_offset: 3600,
            polar_day: false,
            polar_night: false,
            created_at: '2024-08-13T10:30:00Z',
            updated_at: '2024-08-13T10:30:00Z',
          },
        ],
        meta: {
          location: 'Lisbon',
          start_date: '2024-08-01',
          end_date: '2024-08-01',
          total_days: 1,
          cached_records: 0,
          generated_at: '2024-08-13T10:30:00Z',
        },
      };

      mockAxiosInstance.get.mockResolvedValue({ data: mockResponse });

      const result = await sunriseSunsetService.getSunriseSunsetData(
        'Lisbon',
        '2024-08-01',
        '2024-08-01'
      );

      expect(mockAxiosInstance.get).toHaveBeenCalledWith('/sunrise_sunset', {
        params: {
          location: 'Lisbon',
          start_date: '2024-08-01',
          end_date: '2024-08-01',
        },
      });

      expect(result).toEqual(mockResponse);
      expect(result.status).toBe('success');
      expect(result.data).toHaveLength(1);
      expect(result.data?.[0].location).toBe('Lisbon, Portugal');
    });

    it('should return error response from server', async () => {
      const mockErrorResponse: ApiResponse = {
        status: 'error',
        error: 'invalid_location',
        message: 'Location not found',
        timestamp: '2024-08-13T10:30:00Z',
      };

      const axiosError = {
        response: { data: mockErrorResponse },
        request: {},
        message: 'Request failed with status code 422',
        name: 'AxiosError',
        config: {},
        isAxiosError: true,
      };

      mockAxiosInstance.get.mockRejectedValue(axiosError);
      mockAxios.isAxiosError.mockReturnValue(true);

      const result = await sunriseSunsetService.getSunriseSunsetData(
        'InvalidLocation',
        '2024-08-01',
        '2024-08-01'
      );

      expect(result).toEqual(mockErrorResponse);
      expect(result.status).toBe('error');
      expect(result.message).toBe('Location not found');
    });

    it('should throw error when no response received', async () => {
      const axiosError = {
        request: {},
        message: 'Network Error',
        name: 'AxiosError',
        config: {},
        isAxiosError: true,
      };

      mockAxiosInstance.get.mockRejectedValue(axiosError);
      mockAxios.isAxiosError.mockReturnValue(true);

      await expect(
        sunriseSunsetService.getSunriseSunsetData('Lisbon', '2024-08-01', '2024-08-01')
      ).rejects.toThrow('No response from server');
    });

    it('should throw error for network issues', async () => {
      const networkError = new Error('Network failed');

      mockAxiosInstance.get.mockRejectedValue(networkError);
      mockAxios.isAxiosError.mockReturnValue(false);

      await expect(
        sunriseSunsetService.getSunriseSunsetData('Lisbon', '2024-08-01', '2024-08-01')
      ).rejects.toThrow('Network error occurred');
    });

    it('should handle polar region data correctly', async () => {
      const mockPolarResponse: ApiResponse = {
        status: 'success',
        data: [
          {
            id: 1,
            location: 'Svalbard, Norway',
            latitude: 78.9167,
            longitude: 11.9500,
            date: '2024-06-21',
            sunrise: null,
            sunset: null,
            solar_noon: '12:00:00',
            day_length_seconds: 86400,
            day_length_formatted: '24h 0m',
            golden_hour: null,
            timezone: 'Arctic/Longyearbyen',
            utc_offset: 7200,
            polar_day: true,
            polar_night: false,
            created_at: '2024-08-13T10:30:00Z',
            updated_at: '2024-08-13T10:30:00Z',
          },
        ],
      };

      mockAxiosInstance.get.mockResolvedValue({ data: mockPolarResponse });

      const result = await sunriseSunsetService.getSunriseSunsetData(
        'Svalbard',
        '2024-06-21',
        '2024-06-21'
      );

      expect(result.data?.[0].polar_day).toBe(true);
      expect(result.data?.[0].polar_night).toBe(false);
      expect(result.data?.[0].sunrise).toBeNull();
      expect(result.data?.[0].sunset).toBeNull();
      expect(result.data?.[0].day_length_seconds).toBe(86400);
    });
  });

  describe('getRecentLocations', () => {
    it('should return array of location strings', async () => {
      const mockLocationsResponse = {
        data: {
          status: 'success',
          locations: ['Lisbon, Portugal', 'Berlin, Germany', 'Tokyo, Japan'],
          total_count: 3,
          cached_at: '2024-08-13T10:30:00Z',
          cache_expires_in: 3600,
        },
      };

      mockAxiosInstance.get.mockResolvedValue(mockLocationsResponse);

      const result = await sunriseSunsetService.getRecentLocations();

      expect(mockAxiosInstance.get).toHaveBeenCalledWith('/sunrise_sunset/locations');
      expect(result).toEqual(['Lisbon, Portugal', 'Berlin, Germany', 'Tokyo, Japan']);
      expect(result).toHaveLength(3);
    });

    it('should return empty array when API fails', async () => {
      mockAxiosInstance.get.mockRejectedValue(new Error('API Error'));

      const result = await sunriseSunsetService.getRecentLocations();

      expect(result).toEqual([]);
    });

    it('should return empty array when locations property is missing', async () => {
      const mockResponse = {
        data: {
          status: 'success',
          total_count: 0,
        },
      };

      mockAxiosInstance.get.mockResolvedValue(mockResponse);

      const result = await sunriseSunsetService.getRecentLocations();

      expect(result).toEqual([]);
    });
  });

  describe('getHealthStatus', () => {
    it('should return health status when API is healthy', async () => {
      const mockHealthResponse = {
        data: {
          status: 'healthy',
          version: '1.0.0',
          timestamp: '2024-08-13T10:30:00Z',
          uptime_info: {
            rails_env: 'test',
            ruby_version: '3.4.2',
            rails_version: '8.0.2',
          },
          database_status: {
            status: 'connected',
          },
        },
      };

      mockAxiosInstance.get.mockResolvedValue(mockHealthResponse);

      const result = await sunriseSunsetService.getHealthStatus();

      expect(mockAxiosInstance.get).toHaveBeenCalledWith('/health');
      expect(result.status).toBe('healthy');
      expect(result.version).toBe('1.0.0');
      expect(result.database_status.status).toBe('connected');
    });

    it('should return unhealthy status when API fails', async () => {
      mockAxiosInstance.get.mockRejectedValue(new Error('Connection failed'));

      const result = await sunriseSunsetService.getHealthStatus();

      expect(result).toEqual({ status: 'unhealthy' });
    });

    it('should handle server errors gracefully', async () => {
      const serverError = {
        response: {
          status: 500,
          data: { error: 'Internal Server Error' },
        },
      };

      mockAxiosInstance.get.mockRejectedValue(serverError);

      const result = await sunriseSunsetService.getHealthStatus();

      expect(result.status).toBe('unhealthy');
    });
  });

  describe('API configuration', () => {
    it('should create axios instance with correct configuration', () => {
      expect(mockAxios.create).toHaveBeenCalledWith({
        baseURL: 'http://localhost:3000/api/v1',
        timeout: 30000,
        headers: {
          'Content-Type': 'application/json',
        },
      });
    });

    it('should setup request and response interceptors', () => {
      expect(mockAxiosInstance.interceptors.request.use).toHaveBeenCalled();
      expect(mockAxiosInstance.interceptors.response.use).toHaveBeenCalled();
    });
  });
});