# Quick Deployment Guide

## Quick Start: Build and Deploy

### 1. Build Docker Image Locally

```bash
cd backend_app
docker build -t chess-rps-backend:latest .
```

### 2. Push to Docker Hub (Optional)

```bash
# Tag for Docker Hub
docker tag chess-rps-backend:latest YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest

# Login and push
docker login
docker push YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
```

### 3. Deploy on Server

#### On Your Server (SSH into it):

```bash
# Connect to server
ssh root@YOUR_SERVER_IP

# Create deployment directory
mkdir -p /opt/chess-rps
cd /opt/chess-rps

# Clone repository (or copy files)
git clone YOUR_REPO_URL .
cd backend_app/docker

# Create environment file
cat > .env.prod << EOF
DB_HOST=postgres
DB_PORT=5432
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=$(openssl rand -base64 32)
SECRET_AUTH=$(openssl rand -hex 32)
EOF

# Deploy
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

# Run migrations
docker exec -it chess_rps_backend python /app/migrate.py

# Check status
docker-compose -f docker-compose.prod.yml ps
```

### 4. Access Your API

- API: `http://YOUR_SERVER_IP:8000`
- Docs: `http://YOUR_SERVER_IP:8000/docs`
- Health: `http://YOUR_SERVER_IP:8000/health`

## Using Pre-built Image from Registry

If you pushed to Docker Hub, update `docker-compose.prod.yml`:

```yaml
backend:
  image: YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
  # Remove or comment out the 'build' section
```

Then deploy:

```bash
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

## Useful Commands

```bash
# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Restart services
docker-compose -f docker-compose.prod.yml restart

# Stop services
docker-compose -f docker-compose.prod.yml down

# Update application
git pull
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
```

See `DEPLOYMENT.md` for detailed instructions.

