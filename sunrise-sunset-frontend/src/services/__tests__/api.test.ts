import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { ApiResponse } from '../../types';

// Mock simples do axios
const mockAxiosInstance = {
  get: vi.fn(),
  interceptors: {
    request: {
      use: vi.fn(),
    },
    response: {
      use: vi.fn(),
    },
  },
};

const mockAxios = {
  create: vi.fn(() => mockAxiosInstance),
  isAxiosError: vi.fn(),
};

vi.mock('axios', () => ({
  default: mockAxios,
}));

// Importar o serviço após o mock
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
      };

      mockAxiosInstance.get.mockResolvedValue({ data: mockResponse });

      const result = await sunriseSunsetService.getSunriseSunsetData(
        'Lisbon',
        '2024-08-01',
        '2024-08-01'
      );

      expect(result.status).toBe('success');
      expect(result.data).toHaveLength(1);
      expect(result.data?.[0].location).toBe('Lisbon, Portugal');
    });

    it('should handle API errors', async () => {
      const mockErrorResponse: ApiResponse = {
        status: 'error',
        message: 'Location not found',
      };

      const axiosError = {
        response: { data: mockErrorResponse },
      };

      mockAxiosInstance.get.mockRejectedValue(axiosError);
      mockAxios.isAxiosError.mockReturnValue(true);

      const result = await sunriseSunsetService.getSunriseSunsetData(
        'InvalidLocation',
        '2024-08-01',
        '2024-08-01'
      );

      expect(result.status).toBe('error');
      expect(result.message).toBe('Location not found');
    });

    it('should handle network errors', async () => {
      const networkError = new Error('Network failed');
      mockAxiosInstance.get.mockRejectedValue(networkError);
      mockAxios.isAxiosError.mockReturnValue(false);

      await expect(
        sunriseSunsetService.getSunriseSunsetData('Lisbon', '2024-08-01', '2024-08-01')
      ).rejects.toThrow('Network error occurred');
    });
  });

  describe('getRecentLocations', () => {
    it('should return locations array', async () => {
      const mockResponse = {
        data: {
          locations: ['Lisbon', 'Berlin', 'Tokyo'],
        },
      };

      mockAxiosInstance.get.mockResolvedValue(mockResponse);

      const result = await sunriseSunsetService.getRecentLocations();

      expect(result).toEqual(['Lisbon', 'Berlin', 'Tokyo']);
    });

    it('should return empty array on error', async () => {
      mockAxiosInstance.get.mockRejectedValue(new Error('API Error'));

      const result = await sunriseSunsetService.getRecentLocations();

      expect(result).toEqual([]);
    });
  });

  describe('getHealthStatus', () => {
    it('should return health status', async () => {
      const mockResponse = {
        data: {
          status: 'healthy',
          version: '1.0.0',
        },
      };

      mockAxiosInstance.get.mockResolvedValue(mockResponse);

      const result = await sunriseSunsetService.getHealthStatus();

      expect(result.status).toBe('healthy');
      expect(result.version).toBe('1.0.0');
    });

    it('should return unhealthy on error', async () => {
      mockAxiosInstance.get.mockRejectedValue(new Error('Connection failed'));

      const result = await sunriseSunsetService.getHealthStatus();

      expect(result.status).toBe('unhealthy');
    });
  });
});