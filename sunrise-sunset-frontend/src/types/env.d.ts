interface ImportMetaEnv {
  readonly VITE_API_BASE_URL: string;
  readonly VITE_API_TIMEOUT: string;
  readonly VITE_ENABLE_API_LOGGING: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}