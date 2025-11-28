@echo off
REM Helper script for running Alembic migrations on Windows
REM Usage: migrate.bat upgrade head
REM        migrate.bat downgrade -1
REM        migrate.bat revision --autogenerate -m "message"

cd /d %~dp0

if "%1"=="" (
    echo Usage: migrate.bat ^<command^> [args...]
    echo.
    echo Common commands:
    echo   upgrade head          - Apply all pending migrations
    echo   downgrade -1          - Rollback last migration
    echo   revision --autogenerate -m "message" - Create new migration
    echo   current               - Show current migration version
    echo   history               - Show migration history
    exit /b 1
)

python -m alembic %*



