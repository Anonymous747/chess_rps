#!/bin/bash

echo "Starting FastAPI server..."

# Set environment variables for local development
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=chess_rps
export DB_USER=postgres
export DB_PASS=chess_rps_password
export SECRET_AUTH=your-secret-key-here

echo "Environment variables set:"
echo "DB_HOST=$DB_HOST"
echo "DB_PORT=$DB_PORT"
echo "DB_NAME=$DB_NAME"

echo ""
echo "Starting FastAPI server on http://localhost:8000"
echo "API Documentation: http://localhost:8000/docs"
echo ""

# Start the FastAPI server
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
