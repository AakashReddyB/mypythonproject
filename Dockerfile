# Base image
FROM python:3.11-slim

# Create non-root user
RUN useradd -m appuser

# Set working directory
WORKDIR /app

# Copy dependencies first
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Change ownership
RUN chown -R appuser:appuser /app

# Switch user
USER appuser

# Expose port
EXPOSE 5000

# Run application
CMD ["python", "app.py"]
