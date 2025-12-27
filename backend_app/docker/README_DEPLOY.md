# Docker Compose Deployment Guide

## Two Deployment Options

### Option 1: Using Pre-built Image from Docker Hub (Recommended)

This is the easiest and fastest method. Use `docker-compose-simple.yml`:

**On server:**
```bash
cd /opt/chess-rps
# Copy docker-compose-simple.yml to docker-compose.yml
cp backend_app/docker/docker-compose-simple.yml docker-compose.yml

# Edit and replace YOUR_DOCKERHUB_USERNAME
nano docker-compose.yml
# Change: image: YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
# Save: Ctrl+X, Y, Enter

# Deploy
docker-compose pull
docker-compose up -d
```

### Option 2: Build on Server

Use `docker-compose.prod.yml` which builds the image on the server:

**On server:**
```bash
cd /opt/chess-rps/backend_app/docker
docker-compose -f docker-compose.prod.yml up -d --build
```

**Note:** For this to work, you need to have the repository cloned on the server with assets.

## Which File to Use?

- **docker-compose-simple.yml**: Uses pre-built image from Docker Hub (faster, smaller server footprint)
- **docker-compose.prod.yml**: Builds image on server (requires repository and build tools)

For production, **Option 1** (simple.yml) is recommended.

