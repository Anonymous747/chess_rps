@echo off
REM Deployment script for Chess RPS Backend (Windows)
REM Usage: deploy.bat

echo 🚀 Starting Chess RPS Backend Deployment...

REM Check if .env.prod exists
if not exist .env.prod (
    echo ❌ Error: .env.prod file not found!
    echo 📝 Please create .env.prod file with your configuration.
    echo    You can copy env.example and modify it:
    echo    copy env.example .env.prod
    exit /b 1
)

REM Navigate to docker directory
cd /d "%~dp0"

REM Stop existing containers
echo 🛑 Stopping existing containers...
docker-compose -f docker-compose.prod.yml down 2>nul

REM Build and start containers
echo 🔨 Building and starting containers...
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

REM Wait for database to be ready
echo ⏳ Waiting for database to be ready...
timeout /t 5 /nobreak >nul

REM Check if containers are running
docker ps | findstr chess_rps_backend >nul
if errorlevel 1 (
    echo ❌ Error: Backend container failed to start!
    echo 📝 Check logs with: docker-compose -f docker-compose.prod.yml logs
    exit /b 1
)

docker ps | findstr chess_rps_postgres >nul
if errorlevel 1 (
    echo ❌ Error: PostgreSQL container failed to start!
    echo 📝 Check logs with: docker-compose -f docker-compose.prod.yml logs
    exit /b 1
)

echo ✅ Containers are running!

REM Run migrations
echo 📦 Running database migrations...
docker exec -it chess_rps_backend python /app/migrate.py

echo.
echo 🎉 Deployment complete!
echo.
echo 📊 Container status:
docker-compose -f docker-compose.prod.yml ps
echo.
echo 📝 View logs with:
echo    docker-compose -f docker-compose.prod.yml logs -f
echo.
echo 🌐 API available at: http://localhost:8000
echo 📚 API docs at: http://localhost:8000/docs

