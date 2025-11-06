@echo off
echo Starting Chess RPS Backend with Docker...

REM Copy environment file if it doesn't exist
if not exist .env (
    echo Copying environment template...
    copy docker\env.example .env
)

REM Build and start services
echo Building and starting Docker services...
docker-compose -f docker/docker-compose.yml up --build

pause


