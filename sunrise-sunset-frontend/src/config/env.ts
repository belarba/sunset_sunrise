interface EnvironmentConfig {
  apiBaseUrl: string;
  apiTimeout: number;
  enableApiLogging: boolean;
  isDevelopment: boolean;
  isProduction: boolean;
}

export const env: EnvironmentConfig = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api/v1',
  apiTimeout: Number(import.meta.env.VITE_API_TIMEOUT) || 30000,
  enableApiLogging: import.meta.env.VITE_ENABLE_API_LOGGING === 'true',
  isDevelopment: import.meta.env.DEV,
  isProduction: import.meta.env.PROD,
};

// Validação das variáveis obrigatórias
const requiredEnvVars = ['VITE_API_BASE_URL'] as const;

for (const envVar of requiredEnvVars) {
  if (!import.meta.env[envVar]) {
    throw new Error(`Missing required environment variable: ${envVar}`);
  }
}