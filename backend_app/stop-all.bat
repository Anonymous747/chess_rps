@echo off
echo Stopping Chess RPS Backend...

cd /d "%~dp0"

echo Stopping Docker containers...
docker-compose -f docker/docker-compose.yml down

echo.
echo All services stopped.
pause







