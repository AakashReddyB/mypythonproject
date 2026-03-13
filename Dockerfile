# Base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy dependencies first (layer caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]
