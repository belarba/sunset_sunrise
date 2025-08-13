import '@testing-library/jest-dom'
import { vi } from 'vitest'

// Mock do axios
vi.mock('axios', () => ({
  default: {
    create: vi.fn(() => ({
      get: vi.fn(),
      interceptors: {
        request: { use: vi.fn() },
        response: { use: vi.fn() },
      },
    })),
    isAxiosError: vi.fn(),
  },
}))

// Mock simples do styled-components que retorna divs normais
vi.mock('styled-components', () => ({
  default: new Proxy({}, {
    get() {
      return () => 'div'
    }
  }),
  createGlobalStyle: () => () => null,
}))