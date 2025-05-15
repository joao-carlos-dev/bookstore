FROM python:3.11-slim-buster

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && apt-get install -y build-essential netcat

RUN pip install --upgrade pip && pip install poetry==2.1.3

RUN poetry config virtualenvs.create false

COPY pyproject.toml poetry.lock ./
RUN poetry install --only main --no-root

# Copia o restante da aplicação e o wait-for-it.sh
COPY . .

# Dá permissão executável para o wait-for-it.sh
RUN chmod +x wait-for-it.sh

EXPOSE 8000

# Usa o wait-for-it.sh para esperar o banco antes de rodar o Django
CMD ["./wait-for-it.sh", "db:5432", "--", "python", "manage.py", "runserver", "0.0.0.0:8000"]
