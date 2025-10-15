# Use Python 3.11 slim image as base
FROM python:3.11-slim 
# Set working directory inside the container
WORKDIR /app
# Copy the dependencies file
COPY requirements.txt .
# Copy the main application file
COPY app.py .
# Install dependencies
RUN pip install -r requirements.txt
# Expose port 5000 for the Flask app. define on which port to execute
EXPOSE 5000
# Command to run the application
CMD ["python", "app.py"]
