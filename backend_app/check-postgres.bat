@echo off
REM Simple PostgreSQL readiness check script
docker exec chess_rps_postgres pg_isready -U postgres >nul 2>&1
if errorlevel 1 exit /b 1

docker exec chess_rps_postgres psql -U postgres -c "SELECT 1" -d chess_rps >nul 2>&1
if errorlevel 1 exit /b 1

exit /b 0







