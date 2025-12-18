@echo off
echo Fixing alembic_version table...

REM Set environment variables for local development
set DB_HOST=localhost
set DB_PORT=5432
set DB_NAME=chess_rps
set DB_USER=postgres
set DB_PASS=chess_rps_password
set SECRET_AUTH=your-secret-key-here

REM Run the fix script
python fix_alembic_version.py

pause

