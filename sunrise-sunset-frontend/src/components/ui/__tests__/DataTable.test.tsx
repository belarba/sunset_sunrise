// src/components/ui/__tests__/DataTable.test.tsx
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { DataTable } from '../DataTable'
import type { SunriseSunsetData } from '../../../types'

const mockData: SunriseSunsetData[] = [
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
  {
    id: 2,
    location: 'Svalbard, Norway',
    latitude: 78.9167,
    longitude: 11.9500,
    date: '2024-06-15',
    sunrise: null,
    sunset: null,
    solar_noon: null,
    day_length_seconds: 86400,
    day_length_formatted: '24h 0m',
    golden_hour: null,
    timezone: "",
    utc_offset: 0,
    polar_day: true,
    polar_night: false,
    created_at: '2024-08-13T10:30:00Z',
    updated_at: '2024-08-13T10:30:00Z',
  },
]

const mockMeta = {
  location: 'Lisbon',
  total_days: 2,
  cached_records: 1,
}

describe('DataTable', () => {
  it('renderiza a tabela com dados', () => {
    render(<DataTable data={mockData} meta={mockMeta} />)
    
    expect(screen.getByText('Detailed Solar Data')).toBeInTheDocument()
    expect(screen.getByText('Aug 01, 2024')).toBeInTheDocument()
    expect(screen.getByText('Jun 15, 2024')).toBeInTheDocument()
  })

  it('mostra informações de meta quando fornecidas', () => {
    render(<DataTable data={mockData} meta={mockMeta} />)
    
    expect(screen.getByText('Lisbon')).toBeInTheDocument()
    expect(screen.getByText('📅 2 days')).toBeInTheDocument()
    expect(screen.getByText('💾 1 cached records')).toBeInTheDocument()
    expect(screen.getByText('⚡ 1 new fetches')).toBeInTheDocument()
  })

  it('exibe horários corretamente', () => {
    render(<DataTable data={mockData} />)
    
    expect(screen.getByText('06:30:15')).toBeInTheDocument()
    expect(screen.getByText('19:45:22')).toBeInTheDocument()
    expect(screen.getByText('18:45:22')).toBeInTheDocument()
  })

  it('mostra N/A para dados nulos', () => {
    render(<DataTable data={mockData} />)
    
    // A segunda linha (Svalbard) deve mostrar N/A para sunrise/sunset
    const cells = screen.getAllByText('N/A')
    expect(cells.length).toBeGreaterThan(0)
  })

  it('identifica dia polar corretamente', () => {
    render(<DataTable data={mockData} />)
    
    expect(screen.getByText('☀️ Polar Day')).toBeInTheDocument()
    expect(screen.getByText('Normal')).toBeInTheDocument()
  })

  it('formata duração do dia', () => {
    render(<DataTable data={mockData} />)
    
    expect(screen.getByText('13h 15m')).toBeInTheDocument()
    expect(screen.getByText('24h 0m')).toBeInTheDocument()
  })

  it('renderiza tabela vazia sem dados', () => {
    render(<DataTable data={[]} />)
    
    expect(screen.getByText('Detailed Solar Data')).toBeInTheDocument()
    // Tabela ainda deve estar presente, mas sem linhas de dados
    expect(screen.getByRole('table')).toBeInTheDocument()
  })

  it('funciona sem meta informações', () => {
    render(<DataTable data={mockData} />)
    
    expect(screen.getByText('Detailed Solar Data')).toBeInTheDocument()
    expect(screen.getByRole('table')).toBeInTheDocument()
  })
})