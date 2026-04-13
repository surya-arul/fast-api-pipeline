# ============================================
# Stage 1: Builder
# ============================================
FROM python:3.12-slim AS builder

WORKDIR /build

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry

RUN poetry self add poetry-plugin-export

# Copy project dependency files
COPY pyproject.toml poetry.lock ./

# Export prod deps
RUN poetry export -f requirements.txt --output requirements.txt

# Export prod + dev deps (includes debugpy)
RUN poetry export -f requirements.txt --with dev --output requirements-dev.txt

# ============================================
# Stage 2: Runtime (prod base)
# ============================================
FROM python:3.12-slim AS runtime

WORKDIR /app

# Copy Python virtual environment from builder
COPY --from=builder /build/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Allow dynamic PORT passed from docker-compose / env
ARG PORT=8000
ENV PORT=${PORT}

# Copy application code
COPY . .

# Expose port dynamically (Docker runtime will override)
EXPOSE ${PORT}

# Start FastAPI
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT}"]

# ============================================
# Stage 3: Dev (extends runtime, adds debugpy)
# ============================================
FROM runtime AS dev

COPY --from=builder /build/requirements-dev.txt .
RUN pip install --no-cache-dir -r requirements-dev.txt

# CMD is overridden by docker-compose.debug.yml anyway
