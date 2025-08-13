import { render } from '@testing-library/react'

// Re-exportar tudo do React Testing Library
export * from '@testing-library/react'

// Sobrescrever o render se precisar de providers no futuro
export { render }