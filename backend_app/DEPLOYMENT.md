# Backend Deployment Guide

This guide explains how to build a Docker image for the backend and deploy it to a server.

## Prerequisites

- Docker installed on your local machine
- Docker installed on your server
- Docker Compose installed on your server (optional, for easier deployment)
- Access to your server via SSH

## Building the Docker Image

### Option 1: Build Locally and Push to Registry

#### Step 1: Build the Docker Image

From the `backend_app` directory:

```bash
cd backend_app
docker build -t chess-rps-backend:latest .
```

Or with a specific tag:

```bash
docker build -t chess-rps-backend:v1.0.0 .
```

#### Step 2: Tag for Docker Hub (or your registry)

Replace `YOUR_DOCKERHUB_USERNAME` with your Docker Hub username:

```bash
docker tag chess-rps-backend:latest YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
```

#### Step 3: Push to Docker Hub

```bash
# Login to Docker Hub
docker login

# Push the image
docker push YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
```

### Option 2: Build on Server Directly

You can also clone the repository on your server and build directly there:

```bash
# On your server
git clone YOUR_REPO_URL
cd chess_rps/backend_app
docker build -t chess-rps-backend:latest .
```

## Deploying on Your Server

### Option 1: Using Docker Compose (Recommended)

This method is recommended as it handles both the backend and PostgreSQL database.

#### Step 1: Connect to Your Server

```bash
ssh root@YOUR_SERVER_IP
# or
ssh YOUR_USERNAME@YOUR_SERVER_IP
```

#### Step 2: Create Deployment Directory

```bash
mkdir -p /opt/chess-rps
cd /opt/chess-rps
```

#### Step 3: Clone Repository (if not already done)

```bash
git clone YOUR_REPO_URL .
cd backend_app
```

Or if you prefer to use the Docker image from registry:

```bash
mkdir -p /opt/chess-rps
cd /opt/chess-rps
```

#### Step 4: Create Environment File

```bash
cd /opt/chess-rps/backend_app/docker
nano .env.prod
```

Add the following content (modify values as needed):

```env
# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=YOUR_SECURE_PASSWORD_HERE

# Application Configuration
SECRET_AUTH=YOUR_SECURE_JWT_SECRET_KEY_HERE
```

**Important:** 
- Use a strong, random password for `DB_PASS`
- Use a strong, random secret key for `SECRET_AUTH`
- You can generate secrets using: `openssl rand -hex 32`

#### Step 5: Deploy with Docker Compose

**Option A: Using Pre-built Image from Registry**

If you built the image locally and pushed to Docker Hub, edit `docker-compose.prod.yml` and replace the `build` section with `image`:

```yaml
backend:
  image: YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
  # Remove or comment out the 'build' section
  container_name: chess_rps_backend
  # ... rest of configuration
```

Then deploy:

```bash
cd /opt/chess-rps/backend_app/docker
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

**Option B: Building on the Server**

If building on the server:

```bash
cd /opt/chess-rps/backend_app/docker
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
```

#### Step 6: Run Database Migrations

```bash
# Get into the backend container
docker exec -it chess_rps_backend bash

# Inside container, run migrations
cd /app
python migrate.py

# Exit container
exit
```

Or run migrations from host (if you have Python installed):

```bash
cd /opt/chess_rps/backend_app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Copy .env.prod values to env.local or set environment variables
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=chess_rps
export DB_USER=postgres
export DB_PASS=YOUR_SECURE_PASSWORD_HERE
export SECRET_AUTH=YOUR_SECURE_JWT_SECRET_KEY_HERE

python migrate.py
```

#### Step 7: Verify Deployment

```bash
# Check container status
docker ps

# View logs
docker logs chess_rps_backend
docker logs chess_rps_postgres

# Test health endpoint
curl http://localhost:8000/ok
curl http://localhost:8000/health
```

### Option 2: Using Docker Run (Standalone)

If you prefer not to use Docker Compose:

#### Step 1: Start PostgreSQL Container

```bash
docker run -d \
  --name chess_rps_postgres \
  -e POSTGRES_DB=chess_rps \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=YOUR_SECURE_PASSWORD \
  -v postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  --restart unless-stopped \
  postgres:15-alpine
```

#### Step 2: Run Backend Container

If using image from registry:

```bash
docker run -d \
  --name chess_rps_backend \
  --link chess_rps_postgres:postgres \
  -e DB_HOST=postgres \
  -e DB_PORT=5432 \
  -e DB_NAME=chess_rps \
  -e DB_USER=postgres \
  -e DB_PASS=YOUR_SECURE_PASSWORD \
  -e SECRET_AUTH=YOUR_SECURE_JWT_SECRET_KEY \
  -p 8000:8000 \
  --restart unless-stopped \
  YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
```

If using local image:

```bash
docker run -d \
  --name chess_rps_backend \
  --link chess_rps_postgres:postgres \
  -e DB_HOST=postgres \
  -e DB_PORT=5432 \
  -e DB_NAME=chess_rps \
  -e DB_USER=postgres \
  -e DB_PASS=YOUR_SECURE_PASSWORD \
  -e SECRET_AUTH=YOUR_SECURE_JWT_SECRET_KEY \
  -p 8000:8000 \
  --restart unless-stopped \
  chess-rps-backend:latest
```

## Setting Up Reverse Proxy (Nginx)

For production, set up Nginx as a reverse proxy:

### Install Nginx

```bash
sudo apt update
sudo apt install nginx -y
```

### Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/chess-rps
```

Add the following configuration:

```nginx
server {
    listen 80;
    server_name YOUR_DOMAIN_OR_IP;

    client_max_body_size 10M;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts for long-running requests
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

### Enable the Site

```bash
sudo ln -s /etc/nginx/sites-available/chess-rps /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## SSL/HTTPS Setup (Let's Encrypt)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal is set up automatically
```

## Managing the Deployment

### View Logs

```bash
# All services
docker-compose -f docker/docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker/docker-compose.prod.yml logs -f backend
docker-compose -f docker/docker-compose.prod.yml logs -f postgres

# Or with docker run
docker logs -f chess_rps_backend
docker logs -f chess_rps_postgres
```

### Stop Services

```bash
docker-compose -f docker/docker-compose.prod.yml down

# Or with docker run
docker stop chess_rps_backend chess_rps_postgres
```

### Start Services

```bash
docker-compose -f docker/docker-compose.prod.yml up -d

# Or with docker run
docker start chess_rps_postgres chess_rps_backend
```

### Restart Services

```bash
docker-compose -f docker/docker-compose.prod.yml restart

# Or with docker run
docker restart chess_rps_backend chess_rps_postgres
```

### Update Application

```bash
# Pull latest code (if using git)
cd /opt/chess-rps
git pull

# Rebuild and restart
cd backend_app/docker
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

# Run migrations if needed
docker exec -it chess_rps_backend python /app/migrate.py
```

### Backup Database

```bash
# Create backup
docker exec chess_rps_postgres pg_dump -U postgres chess_rps > backup_$(date +%Y%m%d_%H%M%S).sql

# Or with compression
docker exec chess_rps_postgres pg_dump -U postgres chess_rps | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

### Restore Database

```bash
# Restore from backup
docker exec -i chess_rps_postgres psql -U postgres chess_rps < backup_20240101_120000.sql

# Or from compressed backup
gunzip < backup_20240101_120000.sql.gz | docker exec -i chess_rps_postgres psql -U postgres chess_rps
```

## Security Best Practices

1. **Use Strong Passwords**: Generate secure passwords for database and JWT secret
2. **Restrict Firewall**: Only allow necessary ports (80, 443, 22)
3. **Use HTTPS**: Always use SSL/TLS in production
4. **Environment Variables**: Never commit `.env.prod` to version control
5. **Regular Updates**: Keep Docker images and system packages updated
6. **Monitor Logs**: Regularly check logs for suspicious activity
7. **Backup Regularly**: Set up automated database backups

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs chess_rps_backend

# Check if port is already in use
sudo netstat -tlnp | grep 8000

# Check container status
docker ps -a
```

### Database Connection Issues

```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Test database connection
docker exec chess_rps_postgres pg_isready -U postgres

# Check environment variables
docker exec chess_rps_backend env | grep DB_
```

### Permission Issues

```bash
# Check file permissions
ls -la /opt/chess-rps

# Fix ownership if needed
sudo chown -R $USER:$USER /opt/chess-rps
```

## Quick Reference

### Build and Push Image

```bash
# Build
docker build -t chess-rps-backend:latest .

# Tag
docker tag chess-rps-backend:latest YOUR_USERNAME/chess-rps-backend:latest

# Push
docker push YOUR_USERNAME/chess-rps-backend:latest
```

### Deploy on Server

```bash
# Using Docker Compose
cd /opt/chess-rps/backend_app/docker
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d

# Run migrations
docker exec -it chess_rps_backend python /app/migrate.py

# Check status
docker-compose -f docker-compose.prod.yml ps
```

### Useful Commands

```bash
# View logs
docker-compose -f docker/docker-compose.prod.yml logs -f

# Restart
docker-compose -f docker/docker-compose.prod.yml restart

# Stop
docker-compose -f docker/docker-compose.prod.yml down

# Update
docker-compose -f docker/docker-compose.prod.yml up -d --build
```

