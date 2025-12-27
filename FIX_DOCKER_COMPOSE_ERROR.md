# Fix Docker Compose ContainerConfig Error

This error usually means there's a corrupted container or image. Here's how to fix it:

## Quick Fix

```bash
# Stop and remove all containers
docker-compose down

# Remove the problematic containers manually (if needed)
docker rm -f chess_rps_backend chess_rps_postgres 2>/dev/null || true

# Remove images (optional, will re-download)
docker rmi chess-rps-backend:latest postgres:15-alpine 2>/dev/null || true

# Clean up Docker system (optional but helpful)
docker system prune -f

# Now try again
docker-compose up -d
```

## Step-by-Step Fix

### 1. Stop Everything

```bash
cd /opt/chess-rps/backend_app/docker

# Stop containers
docker-compose down

# Or force remove if stuck
docker stop chess_rps_backend chess_rps_postgres 2>/dev/null || true
docker rm -f chess_rps_backend chess_rps_postgres 2>/dev/null || true
```

### 2. Clean Up Corrupted Containers/Images

```bash
# List containers
docker ps -a | grep chess_rps

# Remove any remaining containers
docker rm -f $(docker ps -aq --filter "name=chess_rps") 2>/dev/null || true

# Remove volumes (if you want a fresh start - WARNING: deletes data)
# docker volume rm chess_rps_postgres_data 2>/dev/null || true

# Clean up
docker system prune -f
```

### 3. Recreate Everything

```bash
cd /opt/chess-rps/backend_app/docker

# If using docker-compose.prod.yml
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --force-recreate

# OR if using regular docker-compose.yml
docker-compose down
docker-compose up -d --force-recreate
```

### 4. Alternative: Use Docker Directly

If docker-compose still fails, use docker commands directly:

```bash
# Stop and remove containers
docker stop chess_rps_backend chess_rps_postgres 2>/dev/null || true
docker rm chess_rps_backend chess_rps_postgres 2>/dev/null || true

# Start postgres
docker run -d \
  --name chess_rps_postgres \
  -e POSTGRES_DB=chess_rps \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=YOUR_PASSWORD \
  -v postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  --restart unless-stopped \
  postgres:15-alpine

# Start backend (replace YOUR_USERNAME with your Docker Hub username)
docker run -d \
  --name chess_rps_backend \
  --link chess_rps_postgres:postgres \
  -e DB_HOST=postgres \
  -e DB_PORT=5432 \
  -e DB_NAME=chess_rps \
  -e DB_USER=postgres \
  -e DB_PASS=YOUR_PASSWORD \
  -e SECRET_AUTH=YOUR_SECRET \
  -p 8000:8000 \
  --restart unless-stopped \
  YOUR_USERNAME/chess-rps-backend:latest
```

## If Error Persists

### Check Docker Compose Version

```bash
docker-compose --version

# If old version (< 1.29), try updating or use newer docker compose command:
docker compose version  # Note: no hyphen in newer versions
```

### Update Docker Compose (if old)

```bash
# Install latest docker-compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Or use Docker's built-in compose (newer)
# Just use: docker compose (without hyphen) instead of docker-compose
```

## After Fixing, Check Assets

Once containers are running, check assets:

```bash
# Check if assets exist
docker exec chess_rps_backend ls -la /app/assets/images/

# Test endpoint
curl http://localhost:8000/api/v1/assets/health
curl http://localhost:8000/api/v1/assets/figures/cardinal/white/king
```

