```

FROM python:3.11-slim
 
# Set working directory
WORKDIR /app
 
# Copy requirements file
COPY requirements.txt .
 
# Install dependencies including the wheel file
RUN pip install --no-cache-dir -r requirements.txt
 
# Copy application code
COPY . .
 
# Set environment variables
ENV PORT=8080
# Note: GEMINI_API_KEY should be set in Cloud Run environment variables
# and not hardcoded in the Dockerfile for security reasons
 
# Expose port
EXPOSE 8080
 
# Run the application
CMD exec python -m invoice_analytics

```
