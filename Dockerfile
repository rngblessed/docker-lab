# ---------- Stage 1: Build ----------
FROM python:3.11-slim AS builder

WORKDIR /app

COPY pyproject.toml ./
RUN pip install --upgrade pip
RUN pip install "psycopg[binary]" .[test]  # Устанавливаются зависимости для тестов, включая pytest

COPY . .

# ---------- Stage 2: Test ----------
FROM builder AS test
CMD ["pytest", "tests"]

# ---------- Stage 3: Production ----------
FROM python:3.11-slim

RUN useradd -m appuser

WORKDIR /app
COPY --from=builder /app /app

RUN pip install --no-cache-dir "psycopg[binary]" .

USER appuser

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8094"]
