// src/components/forms/__tests__/SearchForm.test.tsx
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

describe('SearchForm', () => {
  const mockOnSubmit = vi.fn()
  
  beforeEach(() => {
    vi.clearAllMocks()
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

  it('mostra as datas', () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    expect(screen.getByDisplayValue(/2025-08-13/)).toBeInTheDocument() // Data atual
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

  it('tem formulário com campos obrigatórios', () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    // Verificar que os inputs têm os nomes corretos
    const locationInput = screen.getByDisplayValue('') // Campo vazio inicialmente
    const startDateInput = screen.getByDisplayValue(/2025-08-13/)
    
    expect(locationInput).toHaveAttribute('name', 'location')
    expect(startDateInput).toHaveAttribute('name', 'start_date')
  })

  it('mostra título do formulário', () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    expect(screen.getByText('Search Sunrise & Sunset Data')).toBeInTheDocument()
  })
})