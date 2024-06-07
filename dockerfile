# Use the official PostgreSQL image from Docker Hub
FROM postgres:latest

# Define environment variables for username and password
ENV POSTGRES_USER=myuser
ENV POSTGRES_PASSWORD=mypassword

# Set up the initial database
ENV POSTGRES_DB=payment_server_dev

# Expose the PostgreSQL port
EXPOSE 5432
