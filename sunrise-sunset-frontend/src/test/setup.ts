import '@testing-library/jest-dom'
import { vi } from 'vitest'
import React from 'react'

// Types para evitar warnings de any
interface ComponentProps {
  children?: React.ReactNode
  [key: string]: unknown
}

interface AttrsFunction {
  (props: ComponentProps): Record<string, unknown>
}

type AttrsParam = Record<string, unknown> | AttrsFunction

// Mock global do console para evitar logs durante testes
global.console = {
  ...console,
  log: vi.fn(),
  error: vi.fn(),
  warn: vi.fn(),
  info: vi.fn(),
}

// Mock simplificado do styled-components
vi.mock('styled-components', () => {
  const createStyledComponent = (elementType: string) => {
    const styledFunction = () => {
      const Component = React.forwardRef<HTMLElement, ComponentProps>(
        ({ children, ...props }, ref) => {
          return React.createElement(elementType, { ...props, ref }, children);
        }
      );
      Component.displayName = `Styled(${elementType})`;
      return Component;
    };
    
    return styledFunction;
  };

  // Função principal do styled que suporta styled(Component) e styled.div
  const styledMain = (component: string | React.ComponentType) => {
    return () => {
      const Component = React.forwardRef<HTMLElement, ComponentProps>(
        ({ children, ...props }, ref) => {
          if (typeof component === 'string') {
            return React.createElement(component, { ...props, ref }, children);
          }
          // Para componentes React, apenas renderiza como div
          return React.createElement('div', { ...props, ref }, children);
        }
      );
      Component.displayName = `Styled(${typeof component === 'string' ? component : 'Component'})`;
      return Component;
    };
  };

  // Proxy para capturar todas as propriedades HTML (button, div, input, etc.)
  const styled = new Proxy(styledMain, {
    get(target, prop) {
      if (typeof prop === 'string') {
        return createStyledComponent(prop);
      }
      return target[prop];
    }
  });

  return {
    default: styled,
    createGlobalStyle: () => () => null,
    css: () => '',
  };
})

// Mock do react-hot-toast
vi.mock('react-hot-toast', () => ({
  Toaster: () => null,
  toast: {
    success: vi.fn(),
    error: vi.fn(),
    loading: vi.fn(),
    dismiss: vi.fn(),
  },
}))

// Mock do Chart.js
vi.mock('chart.js', () => ({
  Chart: {
    register: vi.fn(),
  },
  CategoryScale: vi.fn(),
  LinearScale: vi.fn(),
  PointElement: vi.fn(),
  LineElement: vi.fn(),
  Title: vi.fn(),
  Tooltip: vi.fn(),
  Legend: vi.fn(),
}))

// Mock do react-chartjs-2
vi.mock('react-chartjs-2', () => ({
  Line: ({ data, options }: { data: unknown; options: unknown }) => 
    React.createElement('canvas', { 
      'data-testid': 'line-chart',
      'data-chart-data': JSON.stringify(data),
      'data-chart-options': JSON.stringify(options)
    }),
}))

// Configurações globais para testes
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
})

// Mock do ResizeObserver
global.ResizeObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
}))