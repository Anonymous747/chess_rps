# Quick Deployment Guide

## Option 1: Deploy Using Docker Hub (Recommended - No Repository Clone)

### 1. Build and Push Image (On Your Local Machine)

```bash
cd backend_app
docker build -t chess-rps-backend:latest .
docker tag chess-rps-backend:latest YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
docker login
docker push YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
```

### 2. Deploy on Server (No Repository Clone Needed!)

```bash
# SSH into server
ssh root@YOUR_SERVER_IP

# Create minimal setup (or use the setup script)
mkdir -p /opt/chess-rps && cd /opt/chess-rps

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: chess_rps_postgres
    environment:
      POSTGRES_DB: ${DB_NAME:-chess_rps}
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASS}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - chess_rps_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-postgres}"]
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
      DB_PASS: ${DB_PASS}
      SECRET_AUTH: ${SECRET_AUTH}
    ports:
      - "8000:8000"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - chess_rps_network
    restart: unless-stopped

volumes:
  postgres_data:

networks:
  chess_rps_network:
EOF

# Create .env file
cat > .env << EOF
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=$(openssl rand -base64 32 | tr -d '\n')
SECRET_AUTH=$(openssl rand -hex 32)
EOF

# Deploy
docker-compose pull
docker-compose up -d
docker exec -it chess_rps_backend python /app/migrate.py
```

**See `DEPLOY_WITHOUT_REPO.md` for detailed instructions.**

## Option 2: Deploy with Repository Clone

### 1. Build Docker Image Locally

```bash
cd backend_app
docker build -t chess-rps-backend:latest .
```

### 2. Deploy on Server

```bash
# Connect to server
ssh root@YOUR_SERVER_IP

# Clone repository
mkdir -p /opt/chess-rps
cd /opt/chess-rps
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

# Deploy (builds on server)
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

# Run migrations
docker exec -it chess_rps_backend python /app/migrate.py
```

### 3. Access Your API

- API: `http://YOUR_SERVER_IP:8000`
- Docs: `http://YOUR_SERVER_IP:8000/docs`
- Health: `http://YOUR_SERVER_IP:8000/health`

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

