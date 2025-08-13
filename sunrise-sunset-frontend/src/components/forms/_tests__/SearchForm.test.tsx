// src/components/forms/__tests__/SearchForm.test.tsx
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { SearchForm } from '../SearchForm'

// Mock do serviço
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

  it('renderiza o formulário corretamente', async () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    expect(screen.getByLabelText(/location/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/start date/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/end date/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /get sunrise/i })).toBeInTheDocument()
  })

  it('mostra localizações recentes', async () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    await waitFor(() => {
      expect(screen.getByText('Lisbon')).toBeInTheDocument()
      expect(screen.getByText('Berlin')).toBeInTheDocument()
      expect(screen.getByText('Tokyo')).toBeInTheDocument()
    })
  })

  it('permite selecionar uma localização recente', async () => {
    const user = userEvent.setup()
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    await waitFor(() => {
      expect(screen.getByText('Lisbon')).toBeInTheDocument()
    })
    
    await user.click(screen.getByText('Lisbon'))
    
    const locationInput = screen.getByLabelText(/location/i) as HTMLInputElement
    expect(locationInput.value).toBe('Lisbon')
  })

  it('valida campos obrigatórios', async () => {
    const user = userEvent.setup()
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    // Limpar o campo de localização
    const locationInput = screen.getByLabelText(/location/i)
    await user.clear(locationInput)
    
    // Tentar submeter o formulário
    await user.click(screen.getByRole('button', { name: /get sunrise/i }))
    
    await waitFor(() => {
      expect(screen.getByText(/location is required/i)).toBeInTheDocument()
    })
    
    expect(mockOnSubmit).not.toHaveBeenCalled()
  })

  it('submete o formulário com dados válidos', async () => {
    const user = userEvent.setup()
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    // Preencher o formulário
    await user.type(screen.getByLabelText(/location/i), 'Paris')
    
    // Submeter
    await user.click(screen.getByRole('button', { name: /get sunrise/i }))
    
    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        location: 'Paris',
        start_date: expect.any(String),
        end_date: expect.any(String),
      })
    })
  })

  it('mostra estado de loading', () => {
    render(<SearchForm onSubmit={mockOnSubmit} loading={true} />)
    
    expect(screen.getByText(/searching/i)).toBeInTheDocument()
    expect(screen.getByRole('button')).toBeDisabled()
  })

  it('valida range mínimo de datas', async () => {
    const user = userEvent.setup()
    render(<SearchForm onSubmit={mockOnSubmit} loading={false} />)
    
    // Preencher com datas iguais (não atende o mínimo)
    await user.type(screen.getByLabelText(/location/i), 'London')
    
    const startDate = screen.getByLabelText(/start date/i)
    const endDate = screen.getByLabelText(/end date/i)
    
    await user.clear(startDate)
    await user.clear(endDate)
    await user.type(startDate, '2024-08-01')
    await user.type(endDate, '2024-08-01')
    
    await user.click(screen.getByRole('button', { name: /get sunrise/i }))
    
    await waitFor(() => {
      expect(screen.getByText(/at least 1 day after/i)).toBeInTheDocument()
    })
  })
})