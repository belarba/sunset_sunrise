import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { SearchForm } from '../SearchForm'

// Mock simples do serviço
vi.mock('../../../services/api', () => ({
  sunriseSunsetService: {
    getRecentLocations: vi.fn().mockResolvedValue(['Lisbon', 'Berlin', 'Tokyo']),
  },
}))

// Mock das funções de data para ter controle sobre a data atual nos testes
const mockCurrentDate = new Date('2025-08-17T12:00:00.000Z')

vi.mock('date-fns', async () => {
  const actual = await vi.importActual('date-fns')
  return {
    ...actual,
    format: vi.fn((date, formatString) => {
      // Para o formato yyyy-MM-dd, retornar a data mockada
      if (formatString === 'yyyy-MM-dd') {
        if (date.getTime() === mockCurrentDate.getTime()) {
          return '2025-08-17'
        }
        // Para addDays(new Date(), 6) seria 2025-08-23
        return '2025-08-23'
      }
      return (actual.format as (date: Date, formatString: string) => string)(date, formatString)
    }),
    addDays: vi.fn((date, days) => {
      const newDate = new Date(date)
      newDate.setDate(newDate.getDate() + days)
      return newDate
    }),
    addYears: vi.fn((date, years) => {
      const newDate = new Date(date)
      newDate.setFullYear(newDate.getFullYear() + years)
      return newDate
    }),
  }
})

describe('SearchForm', () => {
  const mockOnSubmit = vi.fn()
  
  beforeEach(() => {
    vi.clearAllMocks()
    // Simular Date.now() para retornar nossa data mockada
    vi.setSystemTime(mockCurrentDate)
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('renderiza os elementos básicos', () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    // Verificar se os elementos principais estão presentes
    expect(screen.getByText('Location')).toBeInTheDocument()
    expect(screen.getByText('Start Date')).toBeInTheDocument()
    expect(screen.getByText('End Date')).toBeInTheDocument()
    expect(screen.getByText('Get Sunrise & Sunset Data')).toBeInTheDocument()
  })

  it('mostra o campo de localização', () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    const locationInput = screen.getByPlaceholderText(/enter city name/i)
    expect(locationInput).toBeInTheDocument()
  })

  it('mostra as datas', async () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    // Aguardar um pouco para o form se inicializar
    await waitFor(() => {
      const startDateInput = screen.getByDisplayValue('2025-08-17')
      const endDateInput = screen.getByDisplayValue('2025-08-23')
      
      expect(startDateInput).toBeInTheDocument()
      expect(endDateInput).toBeInTheDocument()
    })
  })

  it('mostra localizações recentes após carregamento', async () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    await waitFor(() => {
      expect(screen.getByText('Lisbon')).toBeInTheDocument()
    })
    
    expect(screen.getByText('Berlin')).toBeInTheDocument()
    expect(screen.getByText('Tokyo')).toBeInTheDocument()
  })

  it('permite digitar no campo de localização', async () => {
    const user = userEvent.setup()
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    const locationInput = screen.getByPlaceholderText(/enter city name/i)
    await user.type(locationInput, 'Paris')
    
    expect(locationInput).toHaveValue('Paris')
  })

  it('permite selecionar localização recente', async () => {
    const user = userEvent.setup()
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    // Aguardar localizações carregarem
    await waitFor(() => {
      expect(screen.getByText('Lisbon')).toBeInTheDocument()
    })
    
    const locationInput = screen.getByPlaceholderText(/enter city name/i)
    await user.click(screen.getByText('Lisbon'))
    
    expect(locationInput).toHaveValue('Lisbon')
  })

  it('mostra texto de loading quando loading=true', () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={true} />)
    
    expect(screen.getByText('Searching...')).toBeInTheDocument()
  })

  it('mostra helper text sobre dias mínimos', () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    expect(screen.getByText(/minimum 2 days required/i)).toBeInTheDocument()
  })

  it('tem formulário com campos obrigatórios', async () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    // Aguardar a inicialização do formulário
    await waitFor(() => {
      // Verificar que os inputs têm os nomes corretos
      const locationInput = screen.getByPlaceholderText(/enter city name/i)
      expect(locationInput).toHaveAttribute('name', 'location')
      
      const startDateInput = screen.getByDisplayValue('2025-08-17')
      expect(startDateInput).toHaveAttribute('name', 'start_date')
      
      const endDateInput = screen.getByDisplayValue('2025-08-23')
      expect(endDateInput).toHaveAttribute('name', 'end_date')
    })
  })

  it('mostra título do formulário', () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    expect(screen.getByText('Search Sunrise & Sunset Data')).toBeInTheDocument()
  })
})