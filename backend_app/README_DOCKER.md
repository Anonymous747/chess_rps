# Docker Deployment Overview

This directory contains everything needed to containerize and deploy the Chess RPS backend.

## Files

- **Dockerfile** - Main Docker image definition for the backend
- **.dockerignore** - Files to exclude from Docker build context
- **docker/docker-compose.prod.yml** - Production Docker Compose configuration
- **DEPLOYMENT.md** - Comprehensive deployment guide
- **QUICK_DEPLOY.md** - Quick start deployment guide
- **DOCKER_BUILD.md** - Detailed Docker build instructions

## Quick Start

### Option 1: Deploy Using Docker Hub (Recommended - No Repository Clone)

**Best for production deployments - no source code needed on server.**

1. **Build and push to Docker Hub** (on your local machine):
   ```bash
   cd backend_app
   docker build -t chess-rps-backend:latest .
   docker tag chess-rps-backend:latest YOUR_USERNAME/chess-rps-backend:latest
   docker login
   docker push YOUR_USERNAME/chess-rps-backend:latest
   ```

2. **On server, create minimal files and deploy**:
   ```bash
   # See DEPLOY_WITHOUT_REPO.md for complete instructions
   mkdir -p /opt/chess-rps && cd /opt/chess-rps
   # Create docker-compose.yml (using image from Docker Hub)
   # Create .env file with secrets
   docker-compose pull && docker-compose up -d
   docker exec -it chess_rps_backend python /app/migrate.py
   ```

**See `DEPLOY_WITHOUT_REPO.md` for detailed step-by-step instructions.**

### Option 2: Build on Server

**Requires cloning the repository on the server.**

1. Build image:
   ```bash
   cd backend_app
   docker build -t chess-rps-backend:latest .
   ```

2. Deploy locally (with Docker Compose):
   ```bash
   cd backend_app/docker
   # Create .env.prod file with your configuration
   docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d
   ```

3. On server, clone repo and deploy:
   ```bash
   git clone YOUR_REPO_URL
   cd chess_rps/backend_app/docker
   # Create .env.prod file
   docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
   ```

4. Run migrations:
   ```bash
   docker exec -it chess_rps_backend python /app/migrate.py
   ```

## Documentation

- **🚀 Quick Start**: See `QUICK_DEPLOY.md`
- **📦 Deploy Without Repository Clone**: See `DEPLOY_WITHOUT_REPO.md` ⭐ Recommended
- **📚 Full Guide**: See `DEPLOYMENT.md`
- **🔨 Build Details**: See `DOCKER_BUILD.md`
- **☁️ DigitalOcean**: See `../DIGITALOCEAN_DEPLOYMENT.md`

## Environment Variables

Required environment variables (set in `.env.prod`):

```env
DB_HOST=postgres
DB_PORT=5432
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=your_secure_password
SECRET_AUTH=your_secure_jwt_secret
```

## Architecture

The Docker setup includes:
- **Backend Service**: FastAPI application
- **PostgreSQL Service**: Database (if using docker-compose)
- **Networking**: Bridge network for service communication
- **Volumes**: Persistent database storage

## Health Checks

Both services include health checks:
- Backend: `/ok` endpoint
- PostgreSQL: `pg_isready` command

## Security Features

- Non-root user in container
- Environment variable configuration
- Health checks for container orchestration
- Restart policies for reliability

