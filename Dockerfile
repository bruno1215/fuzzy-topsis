# --- Stage 1: Build Backend ---
FROM python:3.12-slim AS backend-builder
WORKDIR /app/backend
RUN apt-get update && apt-get install -y gcc libpq-dev && rm -rf /var/lib/apt/lists/*
# Criar virtualenv para dependências Python
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/ .

# --- Stage 2: Build Frontend ---
FROM node:22-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# --- Stage 3: Final Image ---
FROM python:3.12-slim
WORKDIR /app

# Instalar Node.js, libpq-dev e supervisor
RUN apt-get update && apt-get install -y \
    curl \
    libpq-dev \
    supervisor \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Copiar backend e virtualenv
COPY --from=backend-builder /opt/venv /opt/venv
COPY --from=backend-builder /app/backend /app/backend
ENV PATH="/opt/venv/bin:$PATH"

# Copiar frontend build e node_modules
COPY --from=frontend-builder /app/frontend/public /app/frontend/public
COPY --from=frontend-builder /app/frontend/.next /app/frontend/.next
COPY --from=frontend-builder /app/frontend/package*.json /app/frontend/
COPY --from=frontend-builder /app/frontend/node_modules /app/frontend/node_modules

# Configurar supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8000 3000

CMD ["/usr/bin/supervisord"]
