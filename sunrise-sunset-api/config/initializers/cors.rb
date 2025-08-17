Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Permitir requisições do frontend Vite (porta 5173) e outras portas comuns
    origins 'http://localhost:5173',          # Vite (React/Vue)
            'http://127.0.0.1:5173',          # Vite alternativo
            'http://localhost:3001',          # Create React App
            'http://127.0.0.1:3001',          # Create React App alternativo
            'http://localhost:3000',          # Same origin (para testes)
            'http://127.0.0.1:3000'           # Same origin alternativo

    # Permitir todos os endpoints da API
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :patch, :put, :delete, :options, :head],
      expose: ['X-Total-Count', 'X-Page', 'X-Per-Page']

    # Permitir endpoint de health check
    resource '/health',
      headers: :any,
      methods: [:get, :options, :head]
  end

  # Para desenvolvimento, também permitir qualquer localhost (opcional, mais permissivo)
  if Rails.env.development?
    allow do
      origins /\Ahttp:\/\/localhost:\d+\z/,     # Qualquer porta localhost
              /\Ahttp:\/\/127\.0\.0\.1:\d+\z/   # Qualquer porta 127.0.0.1

      resource '*',
        headers: :any,
        methods: [:get, :post, :patch, :put, :delete, :options, :head]
    end
  end
end
