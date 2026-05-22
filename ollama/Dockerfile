FROM debian:13-slim

# Instalar dependencias básicas
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Instalar Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh
# Instalar Claude
RUN curl -fsSL https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/bootstrap.sh | bash

# Copiar el binario de Claude a /usr/local/bin para que quede en el PATH
RUN cp /root/.local/bin/claude /usr/local/bin/claude

# Directorio de trabajo
WORKDIR /app

# Exponer puerto de Ollama
EXPOSE 11434

# Comando por defecto: iniciar Ollama
CMD ["ollama", "serve"]
