import '@testing-library/jest-dom'
import { vi } from 'vitest'
import React from 'react'

// Mock global do console para evitar logs durante testes
global.console = {
  ...console,
  log: vi.fn(),
  error: vi.fn(),
  warn: vi.fn(),
  info: vi.fn(),
}

// Mock do styled-components mais completo
vi.mock('styled-components', () => {
  // Função para criar componente estilizado
  const createStyledComponent = (elementType: string) => {
    // Função principal que aceita template literals
    const styledFunction = (strings: TemplateStringsArray, ...values: unknown[]) => {
      const Component = React.forwardRef<any, any>(({ children, ...props }, ref) => {
        return React.createElement(elementType, { ...props, ref }, children);
      });
      Component.displayName = Styled(${elementType});
      
      // Adicionar método attrs
      Component.attrs = (attrsFunction: any) => {
        const AttrsComponent = React.forwardRef<any, any>(({ children, ...props }, ref) => {
          const computedAttrs = typeof attrsFunction === 'function' 
            ? attrsFunction(props) 
            : attrsFunction;
          return React.createElement(elementType, { ...props, ...computedAttrs, ref }, children);
        });
        AttrsComponent.displayName = Styled(${elementType}).attrs;
        return AttrsComponent;
      };
      
      return Component;
    };
    
    // Adicionar método attrs na função principal também
    styledFunction.attrs = (attrsFunction: any) => {
      const AttrsComponent = React.forwardRef<any, any>(({ children, ...props }, ref) => {
        const computedAttrs = typeof attrsFunction === 'function' 
          ? attrsFunction(props) 
          : attrsFunction;
        return React.createElement(elementType, { ...props, ...computedAttrs, ref }, children);
      });
      AttrsComponent.displayName = Styled(${elementType}).attrs;
      return AttrsComponent;
    };
    
    return styledFunction;
  };

  // Proxy para capturar todas as propriedades (button, div, input, etc.)
  const styled = new Proxy({}, {
    get(target, prop) {
      if (typeof prop === 'string') {
        return createStyledComponent(prop);
      }
      return undefined;
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
  Line: ({ data, options }: any) => React.createElement('canvas', { 
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
}));