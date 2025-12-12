# ============================================
# Stage 1: Builder
# ============================================
FROM python:3.12-slim AS builder

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH="/root/.local/bin:${PATH}"

# Copy project dependency files
COPY pyproject.toml poetry.lock* ./

# Install only production dependencies inside a .venv folder
RUN poetry config virtualenvs.in-project true && \
    poetry install --no-interaction --no-ansi --only main

# ============================================
# Stage 2: Runtime
# ============================================
FROM python:3.12-slim

WORKDIR /app

# Copy Python virtual environment from builder
COPY --from=builder /app/.venv /app/.venv

# Add .venv into PATH
ENV PATH="/app/.venv/bin:${PATH}"

# Allow dynamic PORT passed from docker-compose / env
ARG PORT=8000
ENV PORT=${PORT}

# Copy application code
COPY . .

# Expose port dynamically (Docker runtime will override)
EXPOSE ${PORT}

# Start FastAPI
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]
