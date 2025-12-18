@echo off
echo ========================================
echo   Chess RPS - Backend Startup Script
echo ========================================
echo.

REM Change to script directory
cd /d "%~dp0"

REM Check if Docker is running
echo [1/5] Checking Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)
echo Docker is running.
echo.

REM Start Docker containers
echo [2/5] Starting Docker containers...
docker-compose -f docker/docker-compose.yml up -d
if errorlevel 1 (
    echo ERROR: Failed to start Docker containers!
    pause
    exit /b 1
)
echo Docker containers started.
set CONTAINERS_STARTED=1
echo.

REM Wait for PostgreSQL to be ready
echo [3/5] Waiting for PostgreSQL to be ready...
set max_attempts=60
set attempt=0

REM Wait for PostgreSQL to accept connections
:wait_loop
set /a attempt+=1
if %attempt% gtr %max_attempts% (
    echo ERROR: PostgreSQL did not become ready in time!
    echo.
    echo Checking container status...
    docker ps -a --filter "name=chess_rps_postgres"
    echo.
    echo Checking container logs...
    docker logs chess_rps_postgres --tail 20
    echo.
    echo You can try:
    echo   1. Check if container is running: docker ps -a
    echo   2. Check container logs: docker logs chess_rps_postgres
    echo   3. Manually test: docker exec chess_rps_postgres pg_isready -U postgres
    pause
    exit /b 1
)

echo Checking PostgreSQL... (attempt %attempt%/%max_attempts%)

REM Use a separate script to check PostgreSQL (avoids hanging on findstr)
call check-postgres.bat
if errorlevel 1 (
    timeout /t 2 /nobreak >nul
    goto wait_loop
)

echo PostgreSQL is ready!
echo.

REM Run database migrations
echo [4/5] Running database migrations...
python migrate.py upgrade head
if errorlevel 1 (
    echo WARNING: Migration failed, but continuing...
    echo You may need to run migrations manually.
)
echo Migrations completed.
echo.

REM Set environment variables
echo [5/5] Starting FastAPI backend...
set DB_HOST=localhost
set DB_PORT=5432
set DB_NAME=chess_rps
set DB_USER=postgres
set DB_PASS=chess_rps_password
set SECRET_AUTH=your-secret-key-here-change-in-production

echo.
echo ========================================
echo   Backend is starting...
echo ========================================
echo.
echo API will be available at: http://localhost:8000
echo API Documentation: http://localhost:8000/docs
echo Health Check: http://localhost:8000/health
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start FastAPI server
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload

REM Cleanup on exit (only if we started containers)
if defined CONTAINERS_STARTED (
    echo.
    echo Stopping Docker containers...
    docker-compose -f docker/docker-compose.yml down
    echo Done.
)

