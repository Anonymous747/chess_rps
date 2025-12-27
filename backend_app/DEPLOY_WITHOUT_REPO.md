# Deploy Using Docker Hub Image (No Repository Clone Required)

This guide shows how to deploy the backend using a pre-built Docker image from Docker Hub, **without cloning the repository on your server**.

## Overview

Instead of cloning the repository and building on the server, you will:
1. Build and push the image to Docker Hub (from your local machine or CI/CD)
2. On the server, create minimal configuration files
3. Pull and run the image using Docker Compose

## Step 1: Build and Push Image to Docker Hub

### On Your Local Machine

```bash
# Navigate to backend_app directory
cd backend_app

# Build the image
docker build -t chess-rps-backend:latest .

# Tag for Docker Hub (replace YOUR_DOCKERHUB_USERNAME)
docker tag chess-rps-backend:latest YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest

# Login to Docker Hub
docker login

# Push the image
docker push YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
```

### Tag Specific Versions (Recommended)

```bash
# Build with version tag
docker build -t chess-rps-backend:v1.0.0 .
docker tag chess-rps-backend:v1.0.0 YOUR_DOCKERHUB_USERNAME/chess-rps-backend:v1.0.0
docker tag chess-rps-backend:v1.0.0 YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
docker push YOUR_DOCKERHUB_USERNAME/chess-rps-backend:v1.0.0
docker push YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
```

## Step 2: Prepare Docker Compose File on Server

### On Your Server (via SSH)

```bash
# Connect to server
ssh root@YOUR_SERVER_IP

# Create deployment directory
mkdir -p /opt/chess-rps
cd /opt/chess-rps

# Create docker-compose.yml file
nano docker-compose.yml
```

Copy and paste the following content (replace `YOUR_DOCKERHUB_USERNAME`):

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: chess_rps_postgres
    environment:
      POSTGRES_DB: ${DB_NAME:-chess_rps}
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASS:-chess_rps_password}
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - chess_rps_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-postgres} -d ${DB_NAME:-chess_rps}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  backend:
    image: YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
    container_name: chess_rps_backend
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: ${DB_NAME:-chess_rps}
      DB_USER: ${DB_USER:-postgres}
      DB_PASS: ${DB_PASS:-chess_rps_password}
      SECRET_AUTH: ${SECRET_AUTH:-your-secret-key-change-in-production}
    ports:
      - "8000:8000"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - chess_rps_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/ok')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

volumes:
  postgres_data:
    driver: local

networks:
  chess_rps_network:
    driver: bridge
```

Save the file (Ctrl+X, then Y, then Enter in nano).

## Step 3: Create Environment File

```bash
# Create .env file
nano .env
```

Add your configuration (generate secure passwords):

```env
# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=$(openssl rand -base64 32 | tr -d '\n')

# Application Configuration
SECRET_AUTH=$(openssl rand -hex 32)
```

**Or manually set values:**

```env
# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=your_secure_database_password_here

# Application Configuration
SECRET_AUTH=your_secure_jwt_secret_key_here
```

**Generate secure secrets:**

```bash
# Generate database password
openssl rand -base64 32

# Generate JWT secret
openssl rand -hex 32
```

Save the file.

## Step 4: Deploy

```bash
# Make sure you're in the deployment directory
cd /opt/chess-rps

# Pull the latest image and start services
docker-compose pull
docker-compose up -d

# Or combine into one command
docker-compose pull && docker-compose up -d
```

## Step 5: Run Database Migrations

```bash
# Run migrations inside the backend container
docker exec -it chess_rps_backend python /app/migrate.py
```

## Step 6: Verify Deployment

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Test the API
curl http://localhost:8000/ok
curl http://localhost:8000/health
```

## Updating the Application

When you have a new version:

### On Local Machine

```bash
# Build new version
cd backend_app
docker build -t chess-rps-backend:latest .

# Tag and push
docker tag chess-rps-backend:latest YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
docker push YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
```

### On Server

```bash
# SSH into server
ssh root@YOUR_SERVER_IP

# Navigate to deployment directory
cd /opt/chess-rps

# Pull latest image and restart
docker-compose pull
docker-compose up -d

# Run migrations if needed
docker exec -it chess_rps_backend python /app/migrate.py
```

## Quick Reference Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f backend
docker-compose logs -f postgres

# Restart services
docker-compose restart

# Update and restart
docker-compose pull && docker-compose up -d

# Run migrations
docker exec -it chess_rps_backend python /app/migrate.py

# Access backend container shell
docker exec -it chess_rps_backend bash

# Access PostgreSQL
docker exec -it chess_rps_postgres psql -U postgres -d chess_rps
```

## Complete Deployment Script

You can create a simple deployment script on the server:

```bash
# Create deploy script
nano /opt/chess-rps/deploy.sh
```

```bash
#!/bin/bash
set -e

cd /opt/chess-rps
echo "Pulling latest images..."
docker-compose pull
echo "Starting services..."
docker-compose up -d
echo "Running migrations..."
docker exec -it chess_rps_backend python /app/migrate.py
echo "Deployment complete!"
docker-compose ps
```

```bash
# Make executable
chmod +x /opt/chess-rps/deploy.sh

# Run it
/opt/chess-rps/deploy.sh
```

## Advantages of This Approach

✅ **No source code on server** - Only configuration files  
✅ **Faster deployments** - No build time on server  
✅ **Version control** - Easy to rollback by changing image tag  
✅ **Smaller footprint** - No Git, build tools, or source code  
✅ **CI/CD friendly** - Build once, deploy anywhere  
✅ **Security** - Server doesn't need access to your repository  

## File Structure on Server

```
/opt/chess-rps/
├── docker-compose.yml    # Docker Compose configuration
└── .env                  # Environment variables (secrets)
```

That's it! Just 2 files needed on the server.

## Troubleshooting

### Image Not Found

```bash
# Check if image exists
docker pull YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest

# Verify Docker Hub username and image name
docker search YOUR_DOCKERHUB_USERNAME/chess-rps-backend
```

### Pull Authentication Required

If your image is private, you need to login first:

```bash
docker login
docker-compose pull
```

### Migration Errors

```bash
# Check if migrations directory exists in container
docker exec -it chess_rps_backend ls -la /app/alembic/versions

# Run migrations with verbose output
docker exec -it chess_rps_backend python /app/migrate.py upgrade head
```

## Next Steps

1. Set up Nginx reverse proxy (see `DEPLOYMENT.md`)
2. Configure SSL/HTTPS
3. Set up automated backups
4. Configure monitoring

