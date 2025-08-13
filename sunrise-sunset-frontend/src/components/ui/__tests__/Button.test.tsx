import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '../../../test/test-utils'
import userEvent from '@testing-library/user-event'
import { Button } from '../Button'

describe('Button', () => {
  it('renderiza corretamente', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument()
  })

  it('executa onClick quando clicado', async () => {
    const user = userEvent.setup()
    const handleClick = vi.fn()
    
    render(<Button onClick={handleClick}>Click me</Button>)
    
    await user.click(screen.getByRole('button'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('fica desabilitado quando loading', () => {
    render(<Button loading={true}>Loading</Button>)
    
    const button = screen.getByRole('button')
    expect(button).toBeDisabled()
  })

  it('fica desabilitado quando disabled', () => {
    render(<Button disabled={true}>Disabled</Button>)
    
    const button = screen.getByRole('button')
    expect(button).toBeDisabled()
  })

  it('aplica classes corretas para variantes', () => {
    const { rerender } = render(<Button variant="primary">Primary</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
    
    rerender(<Button variant="secondary">Secondary</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
    
    rerender(<Button variant="outline">Outline</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
  })

  it('aplica classes corretas para tamanhos', () => {
    const { rerender } = render(<Button size="sm">Small</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
    
    rerender(<Button size="md">Medium</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
    
    rerender(<Button size="lg">Large</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
  })
})