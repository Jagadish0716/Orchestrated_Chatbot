FROM python:3.10-slim

WORKDIR /app

# Install only necessary system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Streamlit default port
EXPOSE 8501

# Run streamlit directly (No Caddy, No SSL)
# --server.address=0.0.0.0 is critical for K8s networking
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
