FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
ENV ENV_FILE_PATH=/app/.env
CMD \
    alembic stamp head && \
    alembic revision --autogenerate -m 'Initial migration' && \
    alembic upgrade head && \
    uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers ${WORKERS:-1}

