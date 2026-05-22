FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Paso 1: instalar dependencias mínimas necesarias
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        fuse \
        rsync \
        unzip \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Paso 2: descargar e instalar rclone
RUN curl -fsSL https://rclone.org/install.sh -o /install.sh && \
    chmod +x /install.sh && \
    /install.sh && \
    rm /install.sh

# Paso 3: copiar el script de entrada
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
