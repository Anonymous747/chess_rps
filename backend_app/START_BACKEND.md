# How to Start Backend and Docker Containers

## Prerequisites

- Docker Desktop installed and running
- Python 3.8+ installed
- PostgreSQL client (optional, for direct database access)

## Quick Start (Windows)

### Option 1: Using Batch Scripts (Easiest)

1. **Start Docker containers:**
   ```bash
   cd backend_app
   start-docker.bat
   ```
   This will:
   - Build and start PostgreSQL container
   - Expose PostgreSQL on port 5432

2. **Wait for PostgreSQL to be ready** (about 10-30 seconds)

3. **Run database migrations:**
   ```bash
   python migrate.py
   ```
   Or use the batch file:
   ```bash
   migrate.bat
   ```

4. **Start FastAPI backend:**
   ```bash
   start-fastapi.bat
   ```
   This will:
   - Start the FastAPI server on http://localhost:8000
   - Enable auto-reload on code changes

### Option 2: Manual Commands

1. **Start Docker containers:**
   ```bash
   cd backend_app
   docker-compose -f docker/docker-compose.yml up -d
   ```

2. **Check container status:**
   ```bash
   docker ps
   ```
   You should see `chess_rps_postgres` running.

3. **Run database migrations:**
   ```bash
   python migrate.py
   ```

4. **Start FastAPI server:**
   ```bash
   # Set environment variables (Windows PowerShell)
   $env:DB_HOST="localhost"
   $env:DB_PORT="5432"
   $env:DB_NAME="chess_rps"
   $env:DB_USER="postgres"
   $env:DB_PASS="chess_rps_password"
   $env:SECRET_AUTH="your-secret-key-here"
   
   # Start server
   python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

   Or on Windows CMD:
   ```cmd
   set DB_HOST=localhost
   set DB_PORT=5432
   set DB_NAME=chess_rps
   set DB_USER=postgres
   set DB_PASS=chess_rps_password
   set SECRET_AUTH=your-secret-key-here
   python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

## Linux/Mac

### Option 1: All-in-One Script (Recommended)

**Start everything with one command:**
```bash
cd backend_app
chmod +x start-all.sh
./start-all.sh
```

This script will:
1. Check if Docker is running
2. Start Docker containers (PostgreSQL)
3. Wait for PostgreSQL to be ready
4. Run database migrations automatically
5. Start FastAPI backend server

**Stop everything:**
```bash
chmod +x stop-all.sh
./stop-all.sh
```

### Option 2: Manual Steps

1. **Start Docker containers:**
   ```bash
   cd backend_app
   docker-compose -f docker/docker-compose.yml up -d
   ```

2. **Run database migrations:**
   ```bash
   python3 migrate.py
   ```
   Or use the shell script:
   ```bash
   ./migrate.sh
   ```

3. **Start FastAPI server:**
   ```bash
   # Set environment variables
   export DB_HOST=localhost
   export DB_PORT=5432
   export DB_NAME=chess_rps
   export DB_USER=postgres
   export DB_PASS=chess_rps_password
   export SECRET_AUTH=your-secret-key-here
   
   # Start server
   python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```
   Or use the shell script:
   ```bash
   ./start-fastapi.sh
   ```

## Verify Everything is Running

1. **Check Docker containers:**
   ```bash
   docker ps
   ```
   Should show `chess_rps_postgres` container running.

2. **Check FastAPI server:**
   - Open browser: http://localhost:8000
   - Should see: `{"message":"Chess RPS API","version":"1.0.0",...}`
   - API docs: http://localhost:8000/docs
   - Health check: http://localhost:8000/health

3. **Check database connection:**
   ```bash
   # Using docker exec
   docker exec -it chess_rps_postgres psql -U postgres -d chess_rps -c "SELECT version();"
   ```

## Useful Commands

### Docker Commands

**View logs:**
```bash
docker-compose -f docker/docker-compose.yml logs -f
```

**Stop containers:**
```bash
docker-compose -f docker/docker-compose.yml down
```

**Stop and remove volumes (clean data):**
```bash
docker-compose -f docker/docker-compose.yml down -v
```

**Restart containers:**
```bash
docker-compose -f docker/docker-compose.yml restart
```

### Database Commands

**Access PostgreSQL shell:**
```bash
docker exec -it chess_rps_postgres psql -U postgres -d chess_rps
```

**Backup database:**
```bash
docker exec chess_rps_postgres pg_dump -U postgres chess_rps > backup.sql
```

## Troubleshooting

### Port 5432 already in use
If PostgreSQL port is already in use:
1. Stop existing PostgreSQL service
2. Or change the port in `docker-compose.yml`:
   ```yaml
   ports:
     - "5433:5432"  # Use 5433 instead
   ```
   Then update `DB_PORT` environment variable.

### Container won't start
```bash
# Check logs
docker-compose -f docker/docker-compose.yml logs postgres

# Remove and recreate
docker-compose -f docker/docker-compose.yml down -v
docker-compose -f docker/docker-compose.yml up -d
```

### Database connection errors
- Ensure Docker container is running: `docker ps`
- Check environment variables match docker-compose.yml
- Verify database is ready: `docker exec chess_rps_postgres pg_isready -U postgres`

## Environment Variables

Default values (from docker-compose.yml):
- `DB_HOST`: localhost (when connecting from host)
- `DB_PORT`: 5432
- `DB_NAME`: chess_rps
- `DB_USER`: postgres
- `DB_PASS`: chess_rps_password
- `SECRET_AUTH`: your-secret-key-here (change in production!)

## Next Steps

After starting the backend:
1. Backend API will be available at http://localhost:8000
2. WebSocket endpoint: ws://localhost:8000/api/v1/game/ws/{room_code}
3. Update Flutter app endpoint configuration if needed
4. Test API endpoints using http://localhost:8000/docs

