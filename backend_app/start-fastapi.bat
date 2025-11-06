@echo off
echo Starting FastAPI server...

REM Change to the correct directory
cd /d "%~dp0"

REM Set environment variables for local development
set DB_HOST=localhost
set DB_PORT=5432
set DB_NAME=chess_rps
set DB_USER=postgres
set DB_PASS=chess_rps_password
set SECRET_AUTH=your-secret-key-here

echo Environment variables set:
echo DB_HOST=%DB_HOST%
echo DB_PORT=%DB_PORT%
echo DB_NAME=%DB_NAME%
echo Current directory: %CD%

echo.
echo Starting FastAPI server on http://localhost:8000
echo API Documentation: http://localhost:8000/docs
echo.

REM Start the FastAPI server
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload

pause
