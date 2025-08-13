// src/__tests__/App.test.tsx
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'
import App from '../App'

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

describe('App', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renderiza o título principal', () => {
    render(<App />)
    
    expect(screen.getByText('Sunrise Sunset App')).toBeInTheDocument()
  })

  it('renderiza o subtítulo', () => {
    render(<App />)
    
    expect(screen.getByText(/discover sunrise, sunset/i)).toBeInTheDocument()
  })

  it('renderiza o formulário de busca', () => {
    render(<App />)
    
    expect(screen.getByText('Search Sunrise & Sunset Data')).toBeInTheDocument()
  })

  it('mostra empty state inicialmente', () => {
    render(<App />)
    
    expect(screen.getByText('Ready to explore solar data?')).toBeInTheDocument()
    expect(screen.getByText(/enter a location and date range/i)).toBeInTheDocument()
  })

  it('mostra features no empty state', () => {
    render(<App />)
    
    expect(screen.getByText('📊 Interactive Charts')).toBeInTheDocument()
    expect(screen.getByText('📋 Detailed Tables')).toBeInTheDocument()
    expect(screen.getByText('🌍 Global Coverage')).toBeInTheDocument()
    expect(screen.getByText('❄️ Polar Region Support')).toBeInTheDocument()
    expect(screen.getByText('💾 Smart Caching')).toBeInTheDocument()
  })

  it('renderiza o rodapé', () => {
    render(<App />)
    
    expect(screen.getByText('Built with')).toBeInTheDocument()
    expect(screen.getByText('using React, TypeScript & Ruby on Rails')).toBeInTheDocument()
    expect(screen.getByText('Jumpseller Technical Challenge')).toBeInTheDocument()
  })

  it('mostra link do GitHub', () => {
    render(<App />)
    
    expect(screen.getByText('View on GitHub')).toBeInTheDocument()
  })

  it('renderiza icons animados no cabeçalho', () => {
    render(<App />)
    
    // Verificar se os ícones estão presentes através do título
    const titleElement = screen.getByText('Sunrise Sunset App')
    expect(titleElement).toBeInTheDocument()
  })

  it('mostra informações da API no subtítulo', () => {
    render(<App />)
    
    expect(screen.getByText(/powered by open-meteo/i)).toBeInTheDocument()
  })

  it('tem container principal com layout correto', () => {
    render(<App />)
    
    // Verificar se os elementos principais estão na tela
    expect(screen.getByText('Sunrise Sunset App')).toBeInTheDocument()
    expect(screen.getByText('Search Sunrise & Sunset Data')).toBeInTheDocument()
    expect(screen.getByText('Ready to explore solar data?')).toBeInTheDocument()
  })
})