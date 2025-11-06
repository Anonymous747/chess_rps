# Docker Configuration for Chess RPS Backend

This directory contains Docker configurations for running the Chess RPS FastAPI backend with PostgreSQL database.

## Files Overview

- `Dockerfile.postgres` - PostgreSQL database container
- `Dockerfile.fastapi` - FastAPI application container  
- `docker-compose.yml` - Orchestrates both services
- `init-scripts/01-init-db.sql` - Database initialization script
- `start.sh` - Application startup script
- `env.example` - Environment variables template

## Quick Start

1. **Copy environment file:**
   ```bash
   cp docker/env.example .env
   ```

2. **Build and start services:**
   ```bash
   docker-compose up --build
   ```

3. **Access the application:**
   - FastAPI: http://localhost:8000
   - API Docs: http://localhost:8000/docs
   - PostgreSQL: localhost:5432

## Services

### PostgreSQL Database
- **Port:** 5432
- **Database:** chess_rps
- **User:** postgres
- **Password:** chess_rps_password

### FastAPI Application
- **Port:** 8000
- **Auto-reload:** Enabled in development
- **Health check:** /ok endpoint

## Development Commands

```bash
# Start services in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild services
docker-compose up --build

# Access PostgreSQL directly
docker-compose exec postgres psql -U postgres -d chess_rps

# Access FastAPI container
docker-compose exec fastapi bash
```

## Database Schema

The initialization script creates:
- `games` table - Chess game sessions
- `players` table - User information
- `moves` table - Game move history
- Sample data for testing

## Environment Variables

Copy `env.example` to `.env` and modify as needed:
- Database connection settings
- Secret keys for authentication
- API configuration


