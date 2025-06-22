FROM ubuntu:22.04

# Install GIMP and Python
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gimp python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY lineart-pipeline.scm /app/lineart-pipeline.scm
COPY main.py /app/main.py

ENV HOST=0.0.0.0
ENV PORT=8000

CMD ["uvicorn", "main:app", "--host", "${HOST}", "--port", "${PORT}"]
