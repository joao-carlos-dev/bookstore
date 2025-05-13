FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=on \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=2.1.3 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=false \
    POETRY_NO_INTERACTION=1 \
    APP_HOME="/app"

# ENV PATH="$POETRY_HOME/bin:$APP_HOME/.venv/bin:$PATH"

ENV PATH="/app/.venv/bin:$PATH"

# Instala dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    python3-dev \
    libffi-dev \
    libssl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala o Poetry
RUN pip install "poetry==$POETRY_VERSION"

# install postgress dependencies
RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && pip install psycopg2

WORKDIR $APP_HOME

# Copia arquivos de configuração do Poetry
COPY pyproject.toml poetry.lock README.md ./

# Copia o código fonte antes do poetry install para que o pacote seja encontrado
COPY bookstore ./bookstore

# Configura o Poetry para não criar virtualenv (usa o ambiente do container)
RUN poetry config virtualenvs.create false

# Instala as dependências (sem dev para produção)
RUN poetry install --without dev --no-interaction --no-ansi

# Copia o restante do código (se houver outros arquivos fora bookstore)
WORKDIR /app
COPY . /app/

COPY wait-for-db.sh /app/
RUN chmod +x /app/wait-for-db.sh

EXPOSE 8000

CMD ["/app/wait-for-db.sh", "db", "gunicorn", "bookstore.wsgi:application", "--bind", "0.0.0.0:8000"]

# CMD ["/app/wait-for-db.sh", "db", "python", "manage.py", "runserver", "0.0.0.0:8000"]
# CMD ["gunicorn", "bookstore.wsgi:application", "--bind", "0.0.0.0:8000"]
