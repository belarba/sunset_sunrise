import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import App from '../App'
import { sunriseSunsetService } from '../services/api'
import type { ApiResponse } from '../types'

// Mock do serviço
vi.mock('../services/api', () => ({
  sunriseSunsetService: {
    getSunriseSunsetData: vi.fn(),
    getRecentLocations: vi.fn().mockResolvedValue(['Lisbon', 'Berlin']),
  },
}))

// Mock do react-hot-toast
vi.mock('react-hot-toast', () => ({
  Toaster: () => null,
  toast: {
    success: vi.fn(),
    error: vi.fn(),
  },
}))

const mockService = vi.mocked(sunriseSunsetService)

describe('App', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renderiza o título e formulário', () => {
    render(<App />)
    
    expect(screen.getByText('Sunrise Sunset App')).toBeInTheDocument()
    expect(screen.getByText('Search Sunrise & Sunset Data')).toBeInTheDocument()
    expect(screen.getByText('Ready to explore solar data?')).toBeInTheDocument()
  })

  it('mostra empty state inicialmente', () => {
    render(<App />)
    
    expect(screen.getByText('Ready to explore solar data?')).toBeInTheDocument()
    expect(screen.getByText(/enter a location and date range/i)).toBeInTheDocument()
  })

  it('executa busca com sucesso', async () => {
    const user = userEvent.setup()
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
    }

    mockService.getSunriseSunsetData.mockResolvedValue(mockResponse)

    render(<App />)
    
    // Preencher formulário
    await user.type(screen.getByLabelText(/location/i), 'Lisbon')
    
    // Submeter
    await user.click(screen.getByRole('button', { name: /get sunrise/i }))
    
    // Aguardar resultados
    await waitFor(() => {
      expect(screen.getByText('Sunrise, Sunset & Golden Hour Timeline')).toBeInTheDocument()
      expect(screen.getByText('Detailed Solar Data')).toBeInTheDocument()
    })
  })

  it('lida com erro de busca', async () => {
    const user = userEvent.setup()
    
    mockService.getSunriseSunsetData.mockRejectedValue(new Error('Network error'))

    render(<App />)
    
    // Preencher formulário
    await user.type(screen.getByLabelText(/location/i), 'InvalidLocation')
    
    // Submeter
    await user.click(screen.getByRole('button', { name: /get sunrise/i }))
    
    // Deve manter o empty state após erro
    await waitFor(() => {
      expect(screen.getByText('Ready to explore solar data?')).toBeInTheDocument()
    })
  })

  it('lida com resposta de erro da API', async () => {
    const user = userEvent.setup()
    const errorResponse: ApiResponse = {
      status: 'error',
      error: 'invalid_location',
      message: 'Location not found',
      timestamp: '2024-08-13T10:30:00Z',
    }

    mockService.getSunriseSunsetData.mockResolvedValue(errorResponse)

    render(<App />)
    
    // Preencher formulário
    await user.type(screen.getByLabelText(/location/i), 'InvalidLocation')
    
    // Submeter
    await user.click(screen.getByRole('button', { name: /get sunrise/i }))
    
    // Deve manter o empty state após erro da API
    await waitFor(() => {
      expect(screen.getByText('Ready to explore solar data?')).toBeInTheDocument()
    })
  })

  it('mostra loading state durante busca', async () => {
    const user = userEvent.setup()
    
    // Criar promise que não resolve imediatamente
    let resolvePromise: (value: ApiResponse) => void
    const pendingPromise = new Promise<ApiResponse>((resolve) => {
      resolvePromise = resolve
    })
    
    mockService.getSunriseSunsetData.mockReturnValue(pendingPromise)

    render(<App />)
    
    // Preencher e submeter formulário
    await user.type(screen.getByLabelText(/location/i), 'Lisbon')
    await user.click(screen.getByRole('button', { name: /get sunrise/i }))
    
    // Verificar loading state
    expect(screen.getByText(/searching/i)).toBeInTheDocument()
    expect(screen.getByRole('button')).toBeDisabled()
    
    // Resolver promise
    resolvePromise!({
      status: 'success',
      data: [],
      meta: { 
        location: 'Lisbon', 
        total_days: 0, 
        cached_records: 0, 
        start_date: '', 
        end_date: '', 
        generated_at: '' 
      },
    })
  })

  it('renderiza features no empty state', () => {
    render(<App />)
    
    expect(screen.getByText('📊 Interactive Charts')).toBeInTheDocument()
    expect(screen.getByText('📋 Detailed Tables')).toBeInTheDocument()
    expect(screen.getByText('🌍 Global Coverage')).toBeInTheDocument()
    expect(screen.getByText('❄️ Polar Region Support')).toBeInTheDocument()
    expect(screen.getByText('💾 Smart Caching')).toBeInTheDocument()
  })
})