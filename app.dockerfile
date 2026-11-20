FROM python:3.13-slim

WORKDIR /app

COPY app/app.py .
COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["python", "app.py"]