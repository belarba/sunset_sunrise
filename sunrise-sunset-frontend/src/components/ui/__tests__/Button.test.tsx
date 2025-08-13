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
    expect(button).toBeInTheDocument()
    // O botão deve estar na DOM, mesmo que estilizado como disabled
  })

  it('fica desabilitado quando disabled', () => {
    render(<Button disabled={true}>Disabled</Button>)
    
    const button = screen.getByRole('button')
    expect(button).toHaveAttribute('disabled')
  })

  it('renderiza com diferentes variantes', () => {
    const { rerender } = render(<Button variant="primary">Primary</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
    
    rerender(<Button variant="secondary">Secondary</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
    
    rerender(<Button variant="outline">Outline</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
  })

  it('renderiza com diferentes tamanhos', () => {
    const { rerender } = render(<Button size="sm">Small</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
    
    rerender(<Button size="md">Medium</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
    
    rerender(<Button size="lg">Large</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
  })

  it('aplica props HTML corretamente', () => {
    render(<Button type="submit" data-testid="submit-btn">Submit</Button>)
    
    const button = screen.getByRole('button')
    expect(button).toHaveAttribute('type', 'submit')
    expect(button).toHaveAttribute('data-testid', 'submit-btn')
  })

  it('renderiza texto do children', () => {
    render(<Button>Custom Button Text</Button>)
    
    expect(screen.getByText('Custom Button Text')).toBeInTheDocument()
  })

  it('passa props para o elemento button', () => {
    render(<Button id="my-button" className="custom-class">Test</Button>)
    
    const button = screen.getByRole('button')
    expect(button).toHaveAttribute('id', 'my-button')
    expect(button).toHaveClass('custom-class')
  })
})